# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAdd2023CategoryTypes < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Adding category types for new seasons..."
    [
      { src_id: 213, dest_id: 223 }, # LEN 2023
      # (no FINA)
      # (no CSI)
      { src_id: 222, dest_id: 232 }, # FIN
      { src_id: 225, dest_id: 235 }  # UISP
    ].each do |params|
      GogglesDb::CmdCloneCategories.call(
        GogglesDb::Season.find(params[:src_id]),
        GogglesDb::Season.find(params[:dest_id])
      )
      Rails.logger.debug("\033[1;33;32m.\033[0m") # Progress display
    end

    # Append newest FIN categories (M20 & U20) without removing the old U25:
    GogglesDb::CategoryType.create!(
      season_id: 232,
      code: 'M20',
      federation_code: 'A',
      description: 'MASTER 20',
      short_name: 'M20',
      group_name: 'MASTER',
      age_begin: 20,
      age_end: 24,
      relay: false
    )
    GogglesDb::CategoryType.create!(
      season_id: 232,
      code: 'U20',
      federation_code: 'U', # (Educated guess)
      description: 'UNDER 20',
      short_name: 'U20',
      group_name: 'MASTER',
      age_begin: 16,
      age_end: 19,
      relay: false
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
