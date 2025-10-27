# frozen_string_literal: true

class CreateDataImportMeetingIndividualResults < ActiveRecord::Migration[6.1]
  def change
    create_table :data_import_meeting_individual_results do |t|
      # Unique composite key for matching (program_key/swimmer_key)
      t.string :import_key, null: false, limit: 500, comment: 'Unique composite key for this result'

      # Source file tracking
      t.string :phase_file_path, limit: 500, comment: 'Path to phase file source'

      # Entity IDs (null if new entity)
      t.integer :meeting_program_id, comment: 'DB ID if matched, null if new'
      t.integer :swimmer_id, comment: 'DB ID from phase 3'
      t.integer :team_id, comment: 'DB ID from phase 2'
      t.integer :badge_id, comment: 'DB ID (calculated in phase 6)'
      t.integer :meeting_individual_result_id, comment: 'Existing MIR ID if matched'

      # Rank and timing
      t.integer :rank, default: 0, null: false
      t.integer :minutes, limit: 3, default: 0
      t.integer :seconds, limit: 2, default: 0
      t.integer :hundredths, limit: 2, default: 0

      # Additional result fields
      t.boolean :disqualified, default: false, null: false
      t.string :disqualification_code_type_id, limit: 5
      t.decimal :standard_points, precision: 10, scale: 2, default: 0.0
      t.decimal :meeting_points, precision: 10, scale: 2, default: 0.0
      t.decimal :goggle_cup_points, precision: 10, scale: 2, default: 0.0
      t.decimal :reaction_time, precision: 5, scale: 2, default: 0.0
      t.integer :team_points, default: 0
      t.boolean :out_of_race, default: false, null: false
      t.string :notes, limit: 500

      t.timestamps
    end

    add_index :data_import_meeting_individual_results, :import_key, unique: true, name: 'idx_di_mir_import_key'
    add_index :data_import_meeting_individual_results, :meeting_program_id, name: 'idx_di_mir_program_id'
    add_index :data_import_meeting_individual_results, :swimmer_id, name: 'idx_di_mir_swimmer_id'
    add_index :data_import_meeting_individual_results, :team_id, name: 'idx_di_mir_team_id'
    add_index :data_import_meeting_individual_results, :phase_file_path, name: 'idx_di_mir_phase_file'
  end
end
