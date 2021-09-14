# frozen_string_literal: true

require 'goggles_db/version'

class DataFixLapsWithNullParentLink < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Laps: removing laps with missing parent associations..."
    GogglesDb::Lap.where(meeting_individual_result_id: nil).delete_all
    GogglesDb::Lap.where(meeting_program_id: nil).delete_all
    count = GogglesDb::Lap.where('meeting_individual_result_id is null OR meeting_program_id is null').count
    Rails.logger.debug { "Final count: #{count}" }
  end

  def self.down
    # (no-op)
  end
end
