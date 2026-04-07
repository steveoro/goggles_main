# frozen_string_literal: true

# = IssueCleanerJob
#
# Scans all Issue rows deleting any "deletable" that hasn't been updated for over a week.
#
class IssueCleanerJob < ApplicationJob
  queue_as { arguments&.first || 'issues' }

  OBSOLESCENCE_MARK = 1.week

  # Performs the Job; parameters are currently ignored here.
  def perform(*_args)
    GogglesDb::Issue.deletable.where(updated_at: ...OBSOLESCENCE_MARK.ago).delete_all
  end
end
