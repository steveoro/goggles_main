# frozen_string_literal: true

require 'goggles_db/version'

class AddForeignKeysToLaps < ActiveRecord::Migration[6.0]
  def self.up
    add_foreign_key :laps, :meeting_individual_results
    add_foreign_key :laps, :swimmers
    add_foreign_key :laps, :teams

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    remove_foreign_key :laps, :meeting_individual_results
    remove_foreign_key :laps, :swimmers
    remove_foreign_key :laps, :teams
  end
end
