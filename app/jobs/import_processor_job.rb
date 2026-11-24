# frozen_string_literal: true

require 'open3'
require 'shellwords'

# = ImportProcessorJob
#
#   - author......: Steve A.
#   - last updated: 20261123
#
#  Consumes the ImportQueue in two independent passes, at each run:
#
#  1. *batch SQL* rows (macro-transactions pushed by the Admin app as attached SQL files),
#     executed one at a time, in id order, through the DB client;
#  2. *micro-transaction* rows (e.g. users' chrono recordings), solved by IqSolverService.
#
#  A batch failure never prevents the micro-transaction pass.
#
#  A custom queue name can be specified as first argument (defaults to +:iq+).
#  Only one instance runs at a time: an overlapping run is discarded.
#
# == Batch row outcome encoding (no dedicated column):
#
#  - queued  => done: false, process_runs: 0, error_messages blank
#  - running => done: false, process_runs > 0, error_messages blank
#  - applied => done: true, error_messages nil (row & file kept for RETENTION_PERIOD, then purged)
#  - failed  => done: false, error_messages present (the DB client error output)
#
#  A *failed* row blocks every later batch row until it is either reset for a retry
#  (error_messages blank and process_runs 0, e.g. with API "PUT import_queue/:id") or deleted.
#
#  A row still *running* when a new run starts was interrupted (worker crash or restart):
#  it becomes failed with INTERRUPTED_MESSAGE, given its outcome is unknown.
#
# == Examples:
#
#   > ImportProcessorJob.perform_later
#   Or, explicitly:
#   > ImportProcessorJob.perform_later(:iq)
#
class ImportProcessorJob < ApplicationJob # rubocop:disable Metrics/ClassLength
  # Applied batch rows (and their files) are purged when older than this:
  RETENTION_PERIOD = 14.days

  # Max size of the stored DB client error output (the column is a TEXT):
  MAX_ERROR_BYTES = 60_000

  # Error text set on a batch row found still running by a later run:
  INTERRUPTED_MESSAGE = 'interrupted: outcome unknown'

  queue_as { arguments&.first || 'iq' }
  limits_concurrency key: 'import_processor', to: 1, duration: 30.minutes, on_conflict: :discard

  # Runs the batch SQL pass first, then the micro-transaction pass.
  # Batch failures are stored on the rows (never raised).
  #
  # @see IqSolverService, GogglesDb::ImportQueue for transactions details
  #
  def perform(*_args)
    begin
      process_batch_sql
    rescue StandardError => e
      logger.error("[ImportProcessorJob] batch SQL pass aborted: #{e.class}: #{e.message}")
    end
    process_microtransactions
  end

  private

  # Returns, straight from the Rails configuration, the following array composed with
  # the main 4 string connection values:
  # - database name
  # - user name
  # - password
  # - host
  def from_database_config
    environment_config = Rails.configuration.database_configuration.fetch(Rails.env.to_s)
    primary_config = environment_config.fetch('primary', environment_config)

    [
      primary_config['database'],
      primary_config['username'],
      primary_config['password'],
      primary_config['host']
    ]
  end
  #-- -------------------------------------------------------------------------
  #++

  # Batch SQL pass:
  # 1. purges the applied rows older than RETENTION_PERIOD;
  # 2. stops if any row is failed (blocked);
  # 3. turns any row left running into a failed one and stops;
  # 4. runs the queued rows in id order, inside a single maintenance window,
  #    stopping at the first failure.
  def process_batch_sql
    purge_expired_batch_rows
    return log_blocked_queue if failed_batch_rows.exists?
    return mark_interrupted_batch_rows if interrupted_batch_rows.exists?
    return unless queued_batch_rows.exists?

    with_maintenance_window { run_queued_batch_rows }
  end

  # All batch rows not applied yet (queued, running or failed).
  def unfinished_batch_rows
    GogglesDb::ImportQueue.with_batch_sql.where(done: false)
  end

  def failed_batch_rows
    unfinished_batch_rows.where.not(error_messages: [nil, ''])
  end

  def interrupted_batch_rows
    unfinished_batch_rows.where(error_messages: [nil, '']).where('import_queues.process_runs > 0')
  end

  def queued_batch_rows
    unfinished_batch_rows.where(error_messages: [nil, ''], process_runs: [nil, 0])
  end

  # Deletes the applied rows (and their attached files) older than RETENTION_PERIOD.
  # (No maintenance window needed.)
  def purge_expired_batch_rows
    GogglesDb::ImportQueue.with_batch_sql.deletable
                          .where(updated_at: ...RETENTION_PERIOD.ago)
                          .find_each do |iq_row|
      iq_row.data_file.purge
      iq_row.delete
    end
  end

  def log_blocked_queue
    blocking_row = failed_batch_rows.order(:id).first
    logger.warn(
      "[ImportProcessorJob] batch SQL blocked by failed ImportQueue ##{blocking_row.id}: " \
      'retry it (blank error_messages & zero process_runs) or delete it to unblock the queue.'
    )
  end

  def mark_interrupted_batch_rows
    interrupted_batch_rows.order(:id).each do |iq_row|
      logger.error("[ImportProcessorJob] ImportQueue ##{iq_row.id} was interrupted: outcome unknown.")
      iq_row.update!(error_messages: INTERRUPTED_MESSAGE)
    end
  end

  # Toggles the maintenance mode on for the duration of the block, unless it's
  # already on (in which case it's left untouched); always restores it at the end.
  def with_maintenance_window
    toggled = false
    unless GogglesDb::AppParameter.versioning_row.maintenance? # (uncached read)
      GogglesDb::AppParameter.maintenance = true
      toggled = true
    end
    yield
  ensure
    GogglesDb::AppParameter.maintenance = false if toggled
  end

  # Runs the queued rows one by one in id order (including any row queued
  # meanwhile), stopping at the first failure.
  def run_queued_batch_rows
    last_id = 0
    loop do
      iq_row = queued_batch_rows.where('import_queues.id > ?', last_id).order(:id).first
      break if iq_row.nil?

      last_id = iq_row.id
      break if run_batch_row(iq_row) == :failed
    end
  end

  # Runs a single batch row, storing its outcome.
  # Returns either +:applied+ or +:failed+.
  def run_batch_row(iq_row)
    iq_row.update!(process_runs: iq_row.process_runs.to_i + 1) # => running
    error_text = execute_batch_file(iq_row)

    if error_text.nil?
      iq_row.reload.update!(done: true, error_messages: nil)
      logger.info("[ImportProcessorJob] ImportQueue ##{iq_row.id}: SQL OK.")
      return :applied
    end

    store_failure(iq_row, error_text)
    :failed
  end

  # Runs the attached SQL file through the DB client, wrapped in a single transaction.
  # Returns +nil+ on success or the error text otherwise.
  #
  # == NOTE: we can't use a simple connection.execute() anymore due to how
  # the modern mysql2 driver implements paranoid security limits that
  # basically disable multi-statement raw SQL execution, even if wrapped into
  # a single transaction.
  # So, the external client shell file execution is the only way to go from now on.
  def execute_batch_file(iq_row)
    return 'data file missing: nothing to run' unless iq_row.data_file.attached?

    # Download to a temp file (removed at the end of the block) under Dir.tmpdir:
    iq_row.data_file.open(tmpdir: Dir.tmpdir) do |file|
      logger.info("[ImportProcessorJob] executing '#{iq_row.data_file.filename}' (ImportQueue ##{iq_row.id})...")
      _stdout_str, stderr_str, status = run_sql_file(file.path)
      status.success? ? nil : failure_text(stderr_str, status)
    end
  rescue StandardError => e
    "#{e.class}: #{e.message}"
  end

  # Pipes the SQL file into the DB client; the password travels in the
  # environment (MYSQL_PWD), never on the command line.
  # Returns the [stdout, stderr, status] triplet from Open3.capture3.
  def run_sql_file(file_path)
    db_name, db_user, db_pwd, db_host = from_database_config
    client_options = []
    client_options << "--host=#{Shellwords.escape(db_host)}" if db_host.present?
    client_options << "--user=#{Shellwords.escape(db_user)}" if db_user.present?
    client_options << "--database=#{Shellwords.escape(db_name)}"
    cmd = "(echo 'START TRANSACTION;'; cat #{Shellwords.escape(file_path)}; echo 'COMMIT;') | " \
          "mariadb #{client_options.join(' ')}"
    env = db_pwd.present? ? { 'MYSQL_PWD' => db_pwd.to_s } : {}

    Open3.capture3(env, cmd)
  end

  def failure_text(stderr_str, status)
    text = stderr_str.to_s.scrub.strip
    text = "DB client exited with status #{status.exitstatus.inspect} and no error output" if text.blank?
    text.truncate_bytes(MAX_ERROR_BYTES, omission: '...')
  end

  # Stores the error text on the row (=> failed); falls back to its ASCII-only
  # version if the column charset rejects some of its characters.
  def store_failure(iq_row, error_text)
    logger.error("[ImportProcessorJob] ImportQueue ##{iq_row.id}: execution FAILED:\r\n#{error_text}")
    iq_row.reload.update!(error_messages: error_text)
  rescue ActiveRecord::StatementInvalid
    ascii_text = error_text.encode('US-ASCII', invalid: :replace, undef: :replace, replace: '?')
    iq_row.reload.update!(error_messages: ascii_text)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Micro-transaction pass: solves the "standard" queue rows by solving dependencies,
  # respecting any bound queue & starting from its last sibling row.
  #
  # The clean-up of solved rows never touches batch rows (applied ones are retained,
  # failed ones block the batch pass until resolved).
  def process_microtransactions
    GogglesDb::ImportQueue.without_batch_sql.deletable.delete_all # Clean solved rows (including siblings)

    GogglesDb::ImportQueue.without_batch_sql.each do |iq_row|
      if iq_row.sibling_rows.any? # Parent w/ siblings?
        iq_row.update!(process_runs: iq_row.process_runs + 1) # Do nothing and focus always on last remaining sibling as next row
        IqSolverService.new.call(iq_row.sibling_rows.last)

      elsif iq_row.import_queue.present? # Sibling row found?
        iq_row.update!(process_runs: iq_row.process_runs + 1) # Keep IQ row idle if it has a parent

      else
        IqSolverService.new.call(iq_row) # Leaf or ex-parent w/o siblings
      end
    end
  end
end
