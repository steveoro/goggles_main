# frozen_string_literal: true

class AddSeqToImportQueues < ActiveRecord::Migration[6.0]
  def change
    # --- Add a sequential UID for grouping queues by user:
    # (that is, "clustering together" multiple transactions into a single queue,
    #  so that each user can have multiple queues of micro-transactions)
    add_column :import_queues, :uid, :string
    add_index :import_queues, %i[user_id uid], unique: false
  end
end
