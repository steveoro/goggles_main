# frozen_string_literal: true

class DataFixAddMissingSeasons < ActiveRecord::Migration[6.0]
  def self.up
    puts "\r\n--> Adding new seasons..."
    [0, 1].each do |year_digit|
      [
        {
          base_id: 1,
          base_edition: 21,
          base_description: 'Circuito regionale Emilia master CSI',
          season_type_id: GogglesDb::SeasonType::MAS_CSI_ID,
          edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
          timing_type_id: GogglesDb::TimingType::SEMIAUTO_ID,
          individual_rank: true,
          badge_fee: 10.0
        },
        {
          base_id: 2,
          base_description: 'Circuito italiano supermaster FIN',
          season_type_id: GogglesDb::SeasonType::MAS_FIN_ID,
          edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
          timing_type_id: GogglesDb::TimingType::AUTOMATIC_ID,
          individual_rank: true,
          badge_fee: 25.0
        },
        # base_id: 3 => MAS_LEN
        # base_id: 4 => MAS_FINA
        {
          base_id: 5,
          base_edition: 17,
          base_description: 'Circuito italiano master UISP',
          season_type_id: GogglesDb::SeasonType::MAS_UISP_ID,
          edition_type_id: GogglesDb::EditionType::SEASONAL_ID,
          timing_type_id: GogglesDb::TimingType::SEMIAUTO_ID,
          individual_rank: true,
          badge_fee: 10.0
        }
      ].each do |prototype|
        GogglesDb::Season.create!(
          id: 200 + prototype[:base_id] + (10 * year_digit),
          description: "#{prototype[:base_description]} #{2020 + year_digit}/#{2021 + year_digit}",
          edition: prototype[:base_edition].present? ? prototype[:base_edition] + year_digit : 0,
          header_year: "#{2020 + year_digit}/#{2021 + year_digit}",
          begin_date: Date.parse("#{2020 + year_digit}/10/01"),
          end_date: Date.parse("#{2021 + year_digit}/09/30"),
          season_type_id: prototype[:season_type_id],
          edition_type_id: prototype[:edition_type_id],
          timing_type_id: prototype[:timing_type_id],
          individual_rank: prototype[:individual_rank],
          badge_fee: prototype[:badge_fee]
        )
        $stdout.write("\033[1;33;32m.\033[0m") # Progress display
      end
    end
    puts "\r\nDone."
  end

  def self.down
    # Can't go back to old data after this:
    raise ActiveRecord::IrreversibleMigration
  end
  #-- --------------------------------------------------------------------------
  #++
end
