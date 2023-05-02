# frozen_string_literal: true

class SetMoreDefaultBoolValues < ActiveRecord::Migration[6.0]
  def self.up
    change_column :import_queues, :batch_sql, :boolean, null: false, default: false, index: true

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    # (no-op)
  end
end
