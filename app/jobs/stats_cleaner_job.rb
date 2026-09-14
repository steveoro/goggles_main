# frozen_string_literal: true

# = StatsCleanerJob
#
# Purges APIDailyUse & APIDailyUseAgent rows older than the retention period.
class StatsCleanerJob < ApplicationJob
  queue_as 'issues'

  DEFAULT_RETENTION_DAYS = 30

  def perform(retention_days = DEFAULT_RETENTION_DAYS)
    cutoff = retention_days.to_i.days.ago.to_date
    GogglesDb::APIDailyUse.where(day: ...cutoff).delete_all
    GogglesDb::APIDailyUseAgent.where(day: ...cutoff).delete_all
  end
end
