# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[6.0]
  def self.up
    create_table :issues do |t|
      t.references(:user, null: false, foreign_key: true, type: :integer)
      t.string  :code, limit: 3, null: false
      t.text    :req, null: false
      t.integer :priority, limit: 1, default: 0
      t.integer :status, limit: 1, default: 0
      t.timestamps
    end

    add_index :issues, :code
    add_index :issues, :priority
    add_index :issues, :status

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
