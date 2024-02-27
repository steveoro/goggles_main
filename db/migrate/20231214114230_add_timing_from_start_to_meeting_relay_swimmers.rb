# frozen_string_literal: true

class AddTimingFromStartToMeetingRelaySwimmers < ActiveRecord::Migration[6.0]
  def change
    change_table :meeting_relay_swimmers, bulk: true do |t|
      t.integer :length_in_meters, null: false, default: 0, index: true
      t.integer :minutes_from_start, null: false, default: 0, limit: 3
      t.integer :seconds_from_start, null: false, default: 0, limit: 2
      t.integer :hundredths_from_start, null: false, default: 0, limit: 2
    end
  end
end
