# frozen_string_literal: true

class AddSqlBatchFieldToImportQueues < ActiveRecord::Migration[6.0]
  def change
    change_table :import_queues, bulk: true do |t|
      t.boolean :batch_sql, default: false, index: true
    end
  end
end
