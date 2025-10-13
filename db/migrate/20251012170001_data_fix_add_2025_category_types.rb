# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAdd2025CategoryTypes < ActiveRecord::Migration[6.0]
  def self.up
    # Remove unused U25 for the 2024/2025 FIN season (uses categories M20 & U20 instead):
    # (Forgot to do this on last year's data migration)
    GogglesDb::CategoryType.destroy_by(season_id: 242, code: 'U25')

    Rails.logger.debug "\r\n--> Adding category types for new seasons..."
    [
      { src_id: 242, dest_id: 252 } # FIN
      # { src_id: 233, dest_id: 243 }, # no LEN 2025
      # { src_id: 244, dest_id: 254 }, # no FINA 2026
      # (no CSI)
      # { src_id: 245, dest_id: 255 } # no UISP
    ].each do |params|
      GogglesDb::CmdCloneCategories.call(
        GogglesDb::Season.find(params[:src_id]),
        GogglesDb::Season.find(params[:dest_id])
      )
      Rails.logger.debug("\033[1;33;32m.\033[0m") # Progress display
    end

    Rails.logger.debug "\r\nDone."
  end

  def self.down
    # Can't go back to old data after this:
    raise ActiveRecord::IrreversibleMigration
  end
  #-- --------------------------------------------------------------------------
  #++
end
