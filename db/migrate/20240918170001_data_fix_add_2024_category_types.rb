# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAdd2024CategoryTypes < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Adding category types for new seasons..."
    [
      { src_id: 232, dest_id: 242 }, # FIN
      { src_id: 223, dest_id: 233 }, # LEN 2024
      { src_id: 224, dest_id: 234 }, # FINA 2024
      { src_id: 224, dest_id: 244 }, # FINA 2025
      # (no CSI)
      { src_id: 235, dest_id: 245 } # UISP
    ].each do |params|
      GogglesDb::CmdCloneCategories.call(
        GogglesDb::Season.find(params[:src_id]),
        GogglesDb::Season.find(params[:dest_id])
      )
      Rails.logger.debug("\033[1;33;32m.\033[0m") # Progress display
    end

    # Remove U25 for the 2024 FIN season since it uses the new 'M20' & 'U20' categories:
    GogglesDb::CategoryType.destroy_by(season_id: 232, code: 'U25')
    Rails.logger.debug "\r\nDone."
  end

  def self.down
    # Can't go back to old data after this:
    raise ActiveRecord::IrreversibleMigration
  end
  #-- --------------------------------------------------------------------------
  #++
end
