# frozen_string_literal: true

# Restores structure details that predated the migration tree and were lost
# in regenerated dumps:
# - meetings.max_individual_events & meetings.max_individual_events_per_session
#   must default to 3 (the value the production DB & downstream dumps carry).
# - meeting_relay_swimmers needs its length_in_meters index: relay swimmers can
#   be optional, but when present they are sorted by swum distance.
class FixMeetingsDefaultsAndRelayIndex < ActiveRecord::Migration[6.1]
  def change
    change_column_default :meetings, :max_individual_events, from: 2, to: 3
    change_column_default :meetings, :max_individual_events_per_session, from: 2, to: 3
    # (skipped on DBs where the index already exists, like production)
    add_index :meeting_relay_swimmers, :length_in_meters unless index_exists?(:meeting_relay_swimmers, :length_in_meters)
  end
end
