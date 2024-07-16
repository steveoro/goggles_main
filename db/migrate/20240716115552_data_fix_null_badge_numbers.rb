# frozen_string_literal: true

require 'goggles_db/version'

class DataFixNullBadgeNumbers < ActiveRecord::Migration[6.1]
  def self.up
    Rails.logger.debug { "\r\n--> Fix null badge numbers (tot: #{GogglesDb::Badge.where(number: nil).count})..." }
    GogglesDb::Badge.where(number: nil).update_all(number: '?')
    Rails.logger.debug "\r\nDone; updating version number..."

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
  #-- --------------------------------------------------------------------------
  #++
end
