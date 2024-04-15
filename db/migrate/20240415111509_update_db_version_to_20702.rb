# frozen_string_literal: true

require 'goggles_db/version'

class UpdateDbVersionTo20702 < ActiveRecord::Migration[6.1]
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
