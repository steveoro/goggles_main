# frozen_string_literal: true

class UpdateDbVersionTo195 < ActiveRecord::Migration[6.0]
  def self.up
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
