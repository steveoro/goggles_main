# frozen_string_literal: true

class AddMeetingRelaySwimmersCountToMeetingRelayResults < ActiveRecord::Migration[6.0]
  def change
    add_column :meeting_relay_results, :meeting_relay_swimmers_count, :integer, default: 0, null: false
  end
end
