# frozen_string_literal: true

class DataFixAddNextSeasons < ActiveRecord::Migration[6.0]
  def self.up
    # Fix missing edition numbers:
    Rails.logger.debug "\r\n--> Fix missing edition numbers..."
    GogglesDb::Season.where(id: 202).update(edition: 20)
    GogglesDb::Season.where(id: 212).update(edition: 21)

    base_year = 2022
    Rails.logger.debug { "\r\n--> Adding new seasons (#{base_year}~)..." }
    [
      # CSI
      # (last => id: 211, edition: 22)
      {
        id: ((base_year - 2000) * 10) + 1, # => 221
        edition: 23,
        base_description: 'Circuito regionale Emilia master CSI',
        season_type_id: GogglesDb::SeasonType::MAS_CSI_ID,
        edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
        timing_type_id: GogglesDb::TimingType::SEMIAUTO_ID,
        individual_rank: true,
        badge_fee: 10.0
      },

      # FIN
      # (last => id: 212, edition: 21)
      {
        id: ((base_year - 2000) * 10) + 2,
        edition: 22,
        base_description: 'Circuito italiano supermaster FIN',
        season_type_id: GogglesDb::SeasonType::MAS_FIN_ID,
        edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 25.0
      },

      # MAS_LEN
      # => base_id: 3 => id: ((base_year - 2000) * 10) + 3
      #
      # LEN Editions:
      # - 2016 (id: 163)  => ed. 15 (London)
      # - 2018 *MISSING   => ed. 16 (Budapest), 1018-09-2 .. 1018-09-7
      # - 2022 *MISSING   => ed. 17 (Rome), 2022-08-24 .. 2022-09-04
      {
        id: 183,
        edition: 16,
        description: 'Campionato europeo master LEN 2018 (Budapest)',
        header_year: '2018',
        begin_date: Date.parse('2018/09/02'),
        end_date: Date.parse('2018/09/07'),
        season_type_id: GogglesDb::SeasonType::MAS_LEN_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 30.0
      },
      {
        id: 213,
        edition: 17,
        description: 'Campionato europeo master LEN 2022 (Rome)',
        header_year: '2022',
        begin_date: Date.parse('2022/08/24'),
        end_date: Date.parse('2022/09/04'),
        season_type_id: GogglesDb::SeasonType::MAS_LEN_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },

      # MAS_FINA
      # => base_id: 4 => id: ((base_year - 2000) * 10) + 4
      #
      # LEN Editions:
      # - 2015 (id: 144)  => ed. 16th (Kazan, RU)
      # - 2017 (id: 164)  => ed. 17th (Budapest, HUN) => Existing, currently no Meetings!
      # - 2019 *MISSING   => ed. 18th (Gwangju, KOR) (possible id ~184)
      # - 2023 *MISSING   => ed. 19th (Fukuoka, JPN), 2023-08-02 .. 2023-08-11 (possible id ~224)
      # - 2024 FUTUREDEV  => ed. 20th (Doha, QAT) (possible id ~244)
      {
        id: 184,
        edition: 18,
        description: 'Campionato mondiale master FINA 2019 (Gwangju)',
        header_year: '2019',
        begin_date: Date.parse('2022/08/24'),
        end_date: Date.parse('2022/09/04'),
        season_type_id: GogglesDb::SeasonType::MAS_FINA_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },
      {
        id: 224,
        edition: 19,
        description: 'Campionato mondiale master FINA 2022 (Fukuoka)', # <= not a mistake (postponed due to covid)
        header_year: '2022',
        begin_date: Date.parse('2023/08/02'),
        end_date: Date.parse('2023/08/11'),
        season_type_id: GogglesDb::SeasonType::MAS_FINA_ID,
        edition_type_id: GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
        individual_rank: true,
        badge_fee: 50.0
      },

      # UISP
      # (last => id: 215, edition: 18)
      {
        id: ((base_year - 2000) * 10) + 5,
        edition: 19,
        base_description: 'Circuito italiano master UISP',
        season_type_id: GogglesDb::SeasonType::MAS_UISP_ID,
        edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
        timing_type_id: GogglesDb::TimingType::SEMIAUTO_ID,
        individual_rank: true,
        badge_fee: 10.0
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
