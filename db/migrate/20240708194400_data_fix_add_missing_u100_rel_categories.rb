# frozen_string_literal: true

require 'goggles_db/version'

class DataFixAddMissingU100RelCategories < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Fix existing code for U100 relays (currently only in season 232)..."
    GogglesDb::CategoryType.where(season_id: 232, relay: true, code: '80-90').update(code: '80-99')

    # Seldon on some meetings, there will be exceptions in which "out-of-race" U100< relays
    # are accepted for registration even though they won't score in the final ranking.

    # We need some "umbrella" categories to wrap these results during data-import, otherwise
    # the data parsing may fail due to structure expectations (categories can't be nil).

    Rails.logger.debug "\r\n--> Adding missing U100 category types for existing seasons (used as failsafe for out-of-race meeting results exceptions)..."
    # Append newest FIN categories to existing seasons:
    [182, 192, 202, 212, 222, 232].each do |season_id|
      GogglesDb::CategoryType.create!(
        season_id:,
        code: '60-79', # under 20, usually "out-of-race"
        federation_code: 'x0',
        description: 'STAFF. FINO A 79',
        short_name: '60-79',
        group_name: 'MASTER',
        age_begin: 60,
        age_end: 79,
        relay: true,
        out_of_race: true,
        undivided: false
      )
      next if season_id == 232

      GogglesDb::CategoryType.create!(
        season_id:,
        code: '80-99', # under 25, usually "out-of-race"
        federation_code: 'x0',
        description: 'STAFF. 80..99',
        short_name: '80-99',
        group_name: 'MASTER',
        age_begin: 80,
        age_end: 99,
        relay: true,
        out_of_race: true,
        undivided: false
      )
    end
    Rails.logger.debug "\r\nDone."

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
