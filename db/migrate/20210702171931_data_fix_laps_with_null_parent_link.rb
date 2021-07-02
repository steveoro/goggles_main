# frozen_string_literal: true

require 'goggles_db/version'

class DataFixLapsWithNullParentLink < ActiveRecord::Migration[6.0]
  def self.up
    puts "\r\n--> Laps: removing laps with missing parent associations..."
    GogglesDb::Lap.where('meeting_individual_result_id is null').delete_all
    GogglesDb::Lap.where('meeting_program_id is null').delete_all
    count = GogglesDb::Lap.where('meeting_individual_result_id is null OR meeting_program_id is null').count
    puts "Final count: #{count}"
  end

  def self.down
    # (no-op)
  end
end
