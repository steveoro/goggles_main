# frozen_string_literal: true

class SetDefaultBoolValues < ActiveRecord::Migration[6.0]
  def self.up
    change_column :badge_payments, :manual,      :boolean, null: false, default: false, index: true
    change_column :calendars,      :cancelled,   :boolean, null: false, default: false, index: true
    change_column :user_workshops, :autofilled,  :boolean, null: false, default: false, index: true
    change_column :user_workshops, :off_season,  :boolean, null: false, default: false, index: true
    change_column :user_workshops, :confirmed,   :boolean, null: false, default: false, index: true
    change_column :user_workshops, :cancelled,   :boolean, null: false, default: false, index: true
    change_column :user_workshops, :pb_acquired, :boolean, null: false, default: false, index: true
    change_column :user_workshops, :read_only,   :boolean, null: false, default: false, index: true

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
