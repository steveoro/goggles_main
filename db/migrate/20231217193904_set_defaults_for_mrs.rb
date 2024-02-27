# frozen_string_literal: true

class SetDefaultsForMrs < ActiveRecord::Migration[6.0]
  def self.up
    change_column_default(:relay_laps, :length_in_meters, 0)
    change_column_default(:relay_laps, :minutes, 0)
    change_column_default(:relay_laps, :seconds, 0)
    change_column_default(:relay_laps, :hundredths, 0)
    change_column_default(:relay_laps, :minutes_from_start, 0)
    change_column_default(:relay_laps, :seconds_from_start, 0)
    change_column_default(:relay_laps, :hundredths_from_start, 0)
    change_column_default(:relay_laps, :reaction_time, 0.0)

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    # Can't go back to old structure after this:
    raise ActiveRecord::IrreversibleMigration
  end
end
