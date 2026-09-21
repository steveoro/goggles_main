# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAdd2026CategoryTypes < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Adding category types for new seasons..."
    [
      { src_id: 252, dest_id: 262 }, # FIN
      { src_id: 244, dest_id: 253 }, # LEN 2026 (copying categories from FINA, last year)
      { src_id: 244, dest_id: 264 }  # FINA 2027
      # (no CSI)
      # (no UISP)
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
