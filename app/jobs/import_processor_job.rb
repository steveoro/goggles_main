# frozen_string_literal: true

# = ImportProcessorJob
#
#   - author......: Steve A.
#   - last updated: 20221205
#
#  Calls the either the ImportQueue solver service or the SQL batch
#  executor depending on the parameter set within the job creation.
#
#  A custom queue name can be specified as first argument (defaults to +:iq+).
#
# == Examples:
# Create a new IqSolverService job that also does the clean-up of all
# micro-transactions already done:
#
#   > ImportProcessorJob.perform_later
#   Or, explicitly:
#   > ImportProcessorJob.perform_later(:iq)
#
# Create a new SQL batch executor job:
#
#   > ImportProcessorJob.perform_later(:sql)
#
class ImportProcessorJob < ApplicationJob
  queue_as { arguments&.first || 'iq' }

  # DJ error handler callback.
  #
  # === Note: this will be called only if the front-end launching the Job is DelayedJob itself,
  # not ActiveJob.
  #
  # (Meaning: "Delayed::Job.enqueue(job)" instead of "job_class.perform_later")
  def error(job, exception)
    Delayed::Worker.logger.error("\r\n[DelayedJob] #{job.class}\r\nException: #{exception.inspect}")
  end

  # Performs the Job by executing a dedicated service object on each
  # involved row; cleans up all the rows marked as "done" at first.
  #
  # If the ImportQueue contains a micro-transaction, the solver service will be yield.
  # If the ImportQueue contains a batch SQL file instead, the attached file will
  # be executed and the row marked for deletion.
  #
  # @see IqSolverService, GogglesDb::ImportQueue for transactions details
  #
  def perform(*_args)
    if GogglesDb::ImportQueue.with_batch_sql.exists?
      handle_macrotransaction_batch_row
    else
      handle_microtransaction_row
    end
  end

  # Downloads the data file from the specified ImportQueue and runs it as an external
  # batch SQL file using the MySQL client execution parameter through the shell.
  # Marks as solved the specified ImportQueue row.
  def exec_sql(iq_row)
    # Mark the row as done (& deletable) even before execution. We don't want any huge files to
    # stick around in the queue even if the query has the wrong syntax:
    iq_row.update(done: true)
    batch_sql = iq_row.data_file_contents
    return if batch_sql.blank?

    # == NOTE: we can't use a simple connection.execute() anymore due to how
    # the modern mysql2 driver implements paranoid security limits that
    # basically disable multi-statement raw SQL execution, even if wrapped into
    # a single transaction.
    # So, the external client shell file execution is the only way to go from now on.

    # Export the batch data file contents to an external file:
    orig_filename = iq_row.data_file.filename.to_s
    sql_file_name = Rails.root.join('db', 'dump', orig_filename)
    File.open(sql_file_name, 'w+') { |f| f.puts(batch_sql) }

    # Setup MySQL params from Rails config:
    db_name, db_user, db_pwd, db_host = from_database_config

    # Run the batch SQL file and then consume it:
    logger.info("\r\nExecuting '#{orig_filename}' on #{db_name}...")
    cmd = "mysql --host=#{db_host} --user=#{db_user} --password=\"#{db_pwd}\" --database=#{db_name} --execute=\"\\. #{sql_file_name}\""
    _stdout_str, stderr_str, _status = Open3.capture3(cmd)

    logger.info("Cleaning temp file '#{sql_file_name}'...")
    FileUtils.rm(sql_file_name)
    logger.info('SQL OK.') && return if stderr_str.blank?

    logger.error("Execution FAILED:\r\n#{stderr_str}")
    raise stderr_str
  end

  private

  # Returns, straight from the Rails configuration, the following array composed with
  # the main 4 string connection values:
  # - database name
  # - user name
  # - password
  # - host
  def from_database_config
    rails_config = Rails.configuration
    [
      rails_config.database_configuration[Rails.env]['database'],
      rails_config.database_configuration[Rails.env]['username'],
      rails_config.database_configuration[Rails.env]['password'],
      rails_config.database_configuration[Rails.env]['host']
    ]
  end

  # Process any Macro-Transaction queue having a batch file attachment
  # by executing the SQL contained in the file (which should be allegedly ok,
  # as no syntax checking is done on its contents).
  #
  # The SQL execution is done while the "soft maintenance" mode is toggled ON.
  #
  def handle_macrotransaction_batch_row
    # Toggle maintenance only if not already in maintenance:
    maintenance_was_on = GogglesDb::AppParameter.maintenance?
    GogglesDb::AppParameter.maintenance = true unless maintenance_was_on

    # Global deletion & data file purge:
    GogglesDb::ImportQueue.deletable.each do |iq_row|
      iq_row.data_file.purge
      iq_row.delete
    end
    GogglesDb::ImportQueue.with_batch_sql.each do |iq_row|
      exec_sql(iq_row)
    end

    # Disable maintenance unless already in maintenance
    GogglesDb::AppParameter.maintenance = false unless maintenance_was_on
  end

  # Process a "standard" Micro-Transaction queue by solving dependancies,
  # respecting any bound queue & starting from its last sibling row.
  #
  def handle_microtransaction_row
    GogglesDb::ImportQueue.deletable.delete_all # Clean solved rows (including siblings)

    GogglesDb::ImportQueue.without_batch_sql.each do |iq_row|
      if iq_row.sibling_rows.any? # Parent w/ siblings?
        iq_row.update!(process_runs: iq1.process_runs + 1) # Do nothing and focus always on last remaining sibling as next row
        IqSolverService.new.call(iq_row.sibling_rows.last)

      elsif iq_row.import_queue.present? # Sibling row found?
        iq_row.update!(process_runs: iq1.process_runs + 1) # Keep IQ row idle if it has a parent

      else
        IqSolverService.new.call(iq_row) # Leaf or ex-parent w/o siblings
      end
    end
  end
end
