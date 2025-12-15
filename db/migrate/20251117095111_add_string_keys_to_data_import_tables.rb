# frozen_string_literal: true

class AddStringKeysToDataImportTables < ActiveRecord::Migration[6.1]
  def change
    # Add string key columns to DataImportMeetingIndividualResult
    # These allow referencing parent entities when IDs are null (unmatched)
    add_column(:data_import_meeting_individual_results, :swimmer_key, :string, limit: 500,
                                                                               comment: 'Swimmer key from phase3 (e.g., "ROSSI|Mario|1990")')
    add_column(:data_import_meeting_individual_results, :team_key, :string, limit: 500,
                                                                            comment: 'Team key from phase2 (e.g., "ASD Team Name")')
    add_column(:data_import_meeting_individual_results, :meeting_program_key, :string, limit: 500,
                                                                                       comment: 'Program key (e.g., "1-100SL-M25-M")')

    # Add string key columns to DataImportMeetingRelayResult
    add_column(:data_import_meeting_relay_results, :team_key, :string, limit: 500,
                                                                       comment: 'Team key from phase2')
    add_column(:data_import_meeting_relay_results, :meeting_program_key, :string, limit: 500,
                                                                                  comment: 'Program key (e.g., "1-4X50SL-M100-F")')

    # Add string key columns to DataImportMeetingRelaySwimmer
    add_column(:data_import_meeting_relay_swimmers, :swimmer_key, :string, limit: 500,
                                                                           comment: 'Swimmer key from phase3 (e.g., "GRAZIANI|Fabio|1958")')
    add_column(:data_import_meeting_relay_swimmers, :meeting_relay_result_key, :string, limit: 500,
                                                                                        comment: 'Parent MRR import_key reference')

    # Add string key column to DataImportRelayLap
    add_column(:data_import_relay_laps, :meeting_relay_swimmer_key, :string, limit: 500,
                                                                             comment: 'Parent MRS import_key reference')

    # Add string key column to DataImportLap
    add_column(:data_import_laps, :meeting_individual_result_key, :string, limit: 500,
                                                                           comment: 'Parent MIR import_key reference')

    # Fix column naming differences between data_import tables and target tables
    rename_column(:data_import_laps, :breath_number, :breath_cycles) # (same as laps table)
    rename_column(:data_import_relay_laps, :breath_number, :breath_cycles) # (same as relay_laps table)
    # # Never needed (reversible syntax):
    remove_columns(:data_import_meeting_relay_swimmers, :breath_number, :underwater_kicks, :underwater_seconds,
                   type: :integer, default: 0)

    # Add indexes for faster lookups by keys
    add_index(:data_import_meeting_individual_results, :swimmer_key, name: 'idx_di_mir_swimmer_key')
    add_index(:data_import_meeting_individual_results, :team_key, name: 'idx_di_mir_team_key')
    add_index(:data_import_meeting_individual_results, :meeting_program_key, name: 'idx_di_mir_program_key')

    add_index(:data_import_meeting_relay_results, :team_key, name: 'idx_di_mrr_team_key')
    add_index(:data_import_meeting_relay_results, :meeting_program_key, name: 'idx_di_mrr_program_key')

    add_index(:data_import_meeting_relay_swimmers, :swimmer_key, name: 'idx_di_mrs_swimmer_key')
    add_index(:data_import_meeting_relay_swimmers, :meeting_relay_result_key, name: 'idx_di_mrs_mrr_key')

    add_index(:data_import_relay_laps, :meeting_relay_swimmer_key, name: 'idx_di_rlap_mrs_key')

    add_index(:data_import_laps, :meeting_individual_result_key, name: 'idx_di_lap_mir_key')

    # --- Update DB structure versioning: (reversible by manually changing the version numbers, if needed)
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end
end
