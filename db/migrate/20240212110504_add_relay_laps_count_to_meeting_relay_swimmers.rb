# frozen_string_literal: true

class AddRelayLapsCountToMeetingRelaySwimmers < ActiveRecord::Migration[6.0]
  def change
    add_column :meeting_relay_swimmers, :relay_laps_count, :integer, default: 0, null: false
  end
end
