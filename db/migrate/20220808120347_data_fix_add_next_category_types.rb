# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAddNextCategoryTypes < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Adding category types for new seasons..."
    [
      { src_id: 153, dest_id: 183 }, # LEN 2018
      { src_id: 153, dest_id: 213 }, # LEN 2022

      { src_id: 164, dest_id: 184 }, # FINA 2019
      { src_id: 164, dest_id: 224 }, # FINA 2023

      { src_id: 211, dest_id: 221 }, # CSI
      { src_id: 212, dest_id: 222 }, # FIN
      { src_id: 215, dest_id: 225 }  # UISP
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
