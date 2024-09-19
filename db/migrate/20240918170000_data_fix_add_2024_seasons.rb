# frozen_string_literal: true

class DataFixAdd2024Seasons < ActiveRecord::Migration[6.0]
  def self.up
    base_year = 2024
    Rails.logger.debug { "\r\n--> Adding new seasons (#{base_year}~)..." }
    [
      # (no CSI / last => id: 221, edition: 23)
      # => base_id: 1
      # ---

      # FIN (242)
      # => base_id: 2
      # (last => id: 232, edition: 23)
      {
        id: ((base_year - 2000) * 10) + 2,
        edition: 24,
        base_description: 'Circuito italiano supermaster FIN',
        season_type_id: GogglesDb::SeasonType::MAS_FIN_ID,
        edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 30.0
      },

      # MAS_LEN
      # => base_id: 3
      #
      # LEN Editions missing/TODO:
      # - 2022 (id: 213) => ed. 17 (Rome), 2022-08-24 .. 2022-09-04
      # - 2023 (id: 223) => ed. 18 (Madeira), 2023-11-19 .. 2023-11-25 (25m, Winter)
      # - 2024 *MISSING* => ed. 19 (Serbia), 2024-06-25 .. 2022-07-05 (50m, Summer)
      # - 2025 FUTUREDEV => ed. 20 (???), 2025-XX-XX (50m), no calendar yet
      {
        id: 233,
        edition: 19,
        description: 'Campionato Europeo Master LEN 2024 (Belgrade, SRB)',
        header_year: '2024',
        begin_date: Date.parse('2024/06/26'),
        end_date: Date.parse('2024/07/05'),
        season_type_id: GogglesDb::SeasonType::MAS_LEN_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },

      # MAS_FINA
      # => base_id: 4
      #
      # FINA Editions missing:
      # - 2019 (id: 184) => ed. 18th (Gwangju, KOR)
      # - 2023 (id: 224) => ed. 19th (Fukuoka, JPN), 2023-08-02 .. 2023-08-11
      # - 2024 *MISSING* => ed. 20th (Doha, QAT), 2024-02-23 .. 2024-03-03 (possible id ~234)
      # - 2025 *MISSING* => ed. 21th (Singapore) (possible id ~244)
      # ---
      {
        id: 234,
        edition: 20,
        description: 'FINA World Aquatics Master Championship 2024 (Doha, QAT)',
        header_year: '2024',
        begin_date: Date.parse('2024-02-23'),
        end_date: Date.parse('2024-03-03'),
        season_type_id: GogglesDb::SeasonType::MAS_FINA_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },
      {
        id: 244,
        edition: 20,
        description: 'FINA World Aquatics Master Championship 2025 (Singapore)',
        header_year: '2025',
        begin_date: Date.parse('2025-07-26'),
        end_date: Date.parse('2025-08-22'),
        season_type_id: GogglesDb::SeasonType::MAS_FINA_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },

      # UISP (245 / last => id: 235, edition: 20)
      # => base_id: 5
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
