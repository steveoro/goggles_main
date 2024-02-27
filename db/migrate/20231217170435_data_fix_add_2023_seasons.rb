# frozen_string_literal: true

class DataFixAdd2023Seasons < ActiveRecord::Migration[6.0]
  def self.up
    base_year = 2023
    Rails.logger.debug { "\r\n--> Adding new seasons (#{base_year}~)..." }
    [
      # (no CSI)
      # (last => id: 221, edition: 23)
      # ---

      # FIN
      # (last => id: 222, edition: 22)
      {
        id: ((base_year - 2000) * 10) + 2,
        edition: 23,
        base_description: 'Circuito italiano supermaster FIN',
        season_type_id: GogglesDb::SeasonType::MAS_FIN_ID,
        edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 30.0
      },

      # MAS_LEN
      # => base_id: 3 => id: ((base_year - 2000) * 10) + 3
      #
      # LEN Editions:
      # - 2016 (id: 163) => ed. 15 (London)
      # - 2018 (id: 183) => ed. 16 (Budapest), 1018-09-2 .. 1018-09-7
      # - 2022 (id: 213) => ed. 17 (Rome), 2022-08-24 .. 2022-09-04
      # - 2023 *MISSING* => ed. 18 (Madeira), 2023-11-19 .. 2023-11-25 (25m, wintertime)
      # - 2024 FUTUREDEV => ed. 19 (Serbia), 2024-XX-XX .. 2022-XX-XX (50m, springtime)
      {
        id: 223,
        edition: 18,
        description: 'Campionato europeo master LEN 2023 (Madeira)',
        header_year: '2023',
        begin_date: Date.parse('2023/11/19'),
        end_date: Date.parse('2023/11/25'),
        season_type_id: GogglesDb::SeasonType::MAS_LEN_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },

      # MAS_FINA
      # => base_id: 4 => id: ((base_year - 2000) * 10) + 4
      #
      # FINA Editions:
      # - 2015 (id: 144) => ed. 16th (Kazan, RU)
      # - 2017 (id: 164) => ed. 17th (Budapest, HUN) => Existing, currently no Meetings!
      # - 2019 (id: 164) => ed. 18th (Gwangju, KOR) (possible id ~184)
      # - 2023 (id: 164) => ed. 19th (Fukuoka, JPN), 2023-08-02 .. 2023-08-11 (possible id ~224)
      # - 2024 FUTUREDEV => ed. 20th (Doha, QAT) (possible id ~244)
      # ---

      # UISP
      # (last => id: 225, edition: 19)
      {
        id: ((base_year - 2000) * 10) + 5,
        edition: 20,
        base_description: 'Circuito italiano master UISP',
        season_type_id: GogglesDb::SeasonType::MAS_UISP_ID,
        edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
        timing_type_id: GogglesDb::TimingType::SEMIAUTO_ID,
        individual_rank: true,
        badge_fee: 20.0
      }
    ].each do |prototype|
      GogglesDb::Season.create!(
        id: prototype[:id],
        description: prototype[:description] ||
                     "#{prototype[:base_description]} #{base_year}/#{base_year + 1}",
        edition: prototype[:edition],
        header_year: prototype[:header_year] || "#{base_year}/#{base_year + 1}",
        begin_date: prototype[:begin_date] || Date.parse("#{base_year}/10/01"),
        end_date: prototype[:end_date] || Date.parse("#{base_year + 1}/09/30"),
        season_type_id: prototype[:season_type_id],
        edition_type_id: prototype[:edition_type_id],
        timing_type_id: prototype[:timing_type_id],
        individual_rank: prototype[:individual_rank],
        badge_fee: prototype[:badge_fee]
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
