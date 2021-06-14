# frozen_string_literal: true

class AddSupportFieldsToImportQueues < ActiveRecord::Migration[6.0]
  def self.up
    remove_index :import_queues, name: :index_import_queues_on_processed_depth
    remove_index :import_queues, name: :index_import_queues_on_requested_depth
    remove_index :import_queues, name: :index_import_queues_on_solvable_depth

    rename_column :import_queues, :processed_depth, :process_runs
    remove_column :import_queues, :requested_depth
    remove_column :import_queues, :solvable_depth

    change_table :import_queues do |t|
      t.column :bindings_left_count, :integer, default: 0, null: false
      t.column :bindings_left_list, :string, default: nil, null: true
      t.column :error_messages, :text, default: nil, null: true

      # Optional self-reference for siblings/dependant rows:
      t.references(:import_queue, null: true, type: :integer)
    end
  end

  def self.down
    # Can't go back to old structure after this:
    raise ActiveRecord::IrreversibleMigration
  end
end
