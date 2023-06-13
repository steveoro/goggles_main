# frozen_string_literal: true

class AddActiveToUsers < ActiveRecord::Migration[6.0]
  def self.up
    change_table :users do |t|
      t.boolean :active, null: false, default: true, index: true, bulk: true
    end

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    change_table :users do |t|
      t.remove :active
    end
  end
end
