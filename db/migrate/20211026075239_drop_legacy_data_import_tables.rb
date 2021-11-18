# frozen_string_literal: true

class DropLegacyDataImportTables < ActiveRecord::Migration[6.0]
  def self.up
    drop_table :data_import_badges, if_exists: true
    drop_table :data_import_cities, if_exists: true
    drop_table :data_import_laps, if_exists: true
    drop_table :data_import_meeting_entries, if_exists: true

    drop_table :data_import_meeting_individual_results, if_exists: true
    drop_table :data_import_meeting_programs, if_exists: true
    drop_table :data_import_meeting_relay_results, if_exists: true
    drop_table :data_import_meeting_relay_swimmers, if_exists: true

    drop_table :data_import_meeting_sessions, if_exists: true
    drop_table :data_import_meeting_team_scores, if_exists: true
    drop_table :data_import_meetings, if_exists: true
    drop_table :data_import_seasons, if_exists: true
    drop_table :data_import_sessions, if_exists: true

    drop_table :data_import_swimmer_analysis_results, if_exists: true
    drop_table :data_import_swimmers, if_exists: true
    drop_table :data_import_team_analysis_results, if_exists: true
    drop_table :data_import_teams, if_exists: true

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    # Can't go back to old data after this:
    raise ActiveRecord::IrreversibleMigration
  end
end
