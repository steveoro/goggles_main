# frozen_string_literal: true

# = ImportProcessorJob
#
#   - author......: Steve A.
#   - last updated: 20210610
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
    Delayed::Worker.logger.error("[DelayedJob] #{job.class} error: #{exception.msg}")
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
  def perform(*args)
    queue_type = args&.first

    # Standard Micro-Transaction queue: solve dependancies
    if queue_type == 'iq'
      GogglesDb::ImportQueue.deletable.delete_all
      GogglesDb::ImportQueue.without_batch_sql.each do |iq_row|
        IqSolverService.new.call(iq_row)
      end

    # Macro-Transaction queue w/ attachment: SQL batch execution
    else
      GogglesDb::AppParameter.maintenance = true
      # Deletion & data file purge:
      GogglesDb::ImportQueue.deletable.each do |iq_row|
        iq_row.data_file.purge
        iq_row.delete
      end
      GogglesDb::ImportQueue.with_batch_sql.each do |iq_row|
        # Mark the row as done (& deletable) even before execution. We don't want any huge files to
        # stick around even if the query has wrong syntax:
        iq_row.update(done: true)
        batch_sql = iq_row.data_file_contents
        next if batch_sql.blank?

        # Use the connection pool so that we may return the disposed connection afterwards:
        ActiveRecord::Base.connection_pool.with_connection do |con|
          con.exec_query(batch_sql)
        end
      end
      GogglesDb::AppParameter.maintenance = false
    end
  end
end
