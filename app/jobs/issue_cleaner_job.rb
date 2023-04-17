# frozen_string_literal: true

# = IssueCleanerJob
#
# Scans all Issue rows deleting any "deletable" that hasn't been updated for over a week.
#
class IssueCleanerJob < ApplicationJob
  queue_as { arguments&.first || 'issues' }

  OBSOLESCENCE_MARK = 1.week.ago

  # DJ error handler callback.
  #
  # === Note: this will be called only if the front-end launching the Job is DelayedJob itself,
  # not ActiveJob.
  #
  # (Meaning: "Delayed::Job.enqueue(job)" instead of "job_class.perform_later")
  def error(job, exception)
    Delayed::Worker.logger.error("\r\n[DelayedJob] #{job.class}\r\nException: #{exception.inspect}")
  end

  # Performs the Job; parameters are currently ignored here.
  def perform(*_args)
    GogglesDb::Issue.deletable.where('updated_at < ?', OBSOLESCENCE_MARK).delete_all
  end
end
