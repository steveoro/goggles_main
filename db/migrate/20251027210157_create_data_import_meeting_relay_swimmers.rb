# frozen_string_literal: true

class CreateDataImportMeetingRelaySwimmers < ActiveRecord::Migration[6.1]
  def change
    create_table :data_import_meeting_relay_swimmers do |t|
      # Unique composite key for matching (order-mrr_key-swimmer_key)
      t.string :import_key, null: false, limit: 500, comment: 'Unique composite key for this relay swimmer'

      # Parent MRR key (foreign relationship via import_key)
      t.string :parent_import_key, null: false, limit: 500, comment: 'Parent MRR import_key'

      # Source file tracking
      t.string :phase_file_path, limit: 500, comment: 'Path to phase file source'

      # Entity IDs (null if new)
      t.integer :meeting_relay_result_id, comment: 'Parent MRR DB ID'
      t.integer :swimmer_id, comment: 'DB ID from phase 3'
      t.integer :badge_id, comment: 'DB ID (calculated in phase 6)'
      t.integer :meeting_relay_swimmer_id, comment: 'Existing MRS ID if matched'

      # Relay swimmer specific fields
      t.integer :relay_order, default: 0, null: false, comment: 'Order within relay (1-4)'
      t.integer :minutes, limit: 3, default: 0
      t.integer :seconds, limit: 2, default: 0
      t.integer :hundredths, limit: 2, default: 0
      t.integer :length_in_meters, default: 0

      # Additional fields
      t.decimal :reaction_time, precision: 5, scale: 2, default: 0.0
      t.integer :stroke_cycles, default: 0
      t.integer :underwater_kicks, default: 0
      t.integer :underwater_seconds, default: 0
      t.integer :breath_number, default: 0

      t.timestamps
    end

    add_index :data_import_meeting_relay_swimmers, :import_key, unique: true, name: 'idx_di_mrs_import_key'
    add_index :data_import_meeting_relay_swimmers, :parent_import_key, name: 'idx_di_mrs_parent_key'
    add_index :data_import_meeting_relay_swimmers, :meeting_relay_result_id, name: 'idx_di_mrs_mrr_id'
    add_index :data_import_meeting_relay_swimmers, :swimmer_id, name: 'idx_di_mrs_swimmer_id'
    add_index :data_import_meeting_relay_swimmers, :phase_file_path, name: 'idx_di_mrs_phase_file'
  end
end
