# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAddCategoryTypes < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Adding category types for new seasons..."
    [
      { src_id: 191, dest_id: 201 },
      { src_id: 192, dest_id: 202 },
      { src_id: 165, dest_id: 205 },
      { src_id: 191, dest_id: 211 },
      { src_id: 192, dest_id: 212 },
      { src_id: 165, dest_id: 215 }
    ].each do |params|
      GogglesDb::CmdCloneCategories.call(
        GogglesDb::Season.find(params[:src_id]),
        GogglesDb::Season.find(params[:dest_id])
      )
      Rails.logger.debug("\033[1;33;32m.\033[0m") # Progress display
    end

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
    Rails.logger.debug "\r\nDone."
  end

  def self.down
    # Can't go back to old data after this:
    raise ActiveRecord::IrreversibleMigration
  end
  #-- --------------------------------------------------------------------------
  #++
end
