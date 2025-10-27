# frozen_string_literal: true

class CreateDataImportRelayLaps < ActiveRecord::Migration[6.1]
  def change
    create_table :data_import_relay_laps do |t|
      # Unique composite key for matching (mrr_key/length_in_meters)
      t.string :import_key, null: false, limit: 500, comment: 'Unique composite key for this relay lap'

      # Parent MRR key (foreign relationship via import_key)
      t.string :parent_import_key, null: false, limit: 500, comment: 'Parent MRR import_key'

      # Source file tracking
      t.string :phase_file_path, limit: 500, comment: 'Path to phase file source'

      # Entity IDs (null if new)
      t.integer :meeting_relay_result_id, comment: 'Parent MRR DB ID'
      t.integer :relay_lap_id, comment: 'Existing RelayLap ID if matched'

      # Lap details
      t.integer :length_in_meters, null: false, comment: 'Lap distance (50, 100, 150, etc.)'
      t.integer :minutes, limit: 3, default: 0
      t.integer :seconds, limit: 2, default: 0
      t.integer :hundredths, limit: 2, default: 0

      # Additional fields
      t.decimal :reaction_time, precision: 5, scale: 2, default: 0.0
      t.integer :stroke_cycles, default: 0
      t.integer :underwater_kicks, default: 0
      t.integer :underwater_seconds, default: 0
      t.integer :breath_number, default: 0

      t.timestamps
    end

    add_index :data_import_relay_laps, :import_key, unique: true, name: 'idx_di_rel_laps_import_key'
    add_index :data_import_relay_laps, :parent_import_key, name: 'idx_di_rel_laps_parent_key'
    add_index :data_import_relay_laps, :meeting_relay_result_id, name: 'idx_di_rel_laps_mrr_id'
    add_index :data_import_relay_laps, :phase_file_path, name: 'idx_di_rel_laps_phase_file'
  end
end
