# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'teams/current_swimmers.html.haml' do
  # Test basic/required content:
  context 'when rendering with valid data and a valid user logged-in,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:current_user) { GogglesDb::User.first(50).sample }
    let(:fixture_row) { GogglesDb::Team.includes(:team_affiliations).joins(:team_affiliations).first(5).sample }
    let(:last_affiliations) do
      [
        GogglesDb::TeamAffiliation.includes(:team, season: :season_type).joins(:team, season: :season_type)
                                  .where(team_id: fixture_row.id, seasons: { season_type_id: GogglesDb::SeasonType.mas_csi.id })
                                  .order(:begin_date)
                                  .last,
        GogglesDb::TeamAffiliation.includes(:team, season: :season_type).joins(:team, season: :season_type)
                                  .where(team_id: fixture_row.id, seasons: { season_type_id: GogglesDb::SeasonType.mas_fin.id })
                                  .order(:begin_date)
                                  .last
      ].compact
    end
    let(:team_affiliation) { last_affiliations.first }
    let(:all_badges_per_type) { GogglesDb::Badge.where(team_affiliation_id: team_affiliation.id) }
    let(:fixture_swimmers) do
      GogglesDb::Badge.where(team_affiliation_id: team_affiliation.id).map(&:swimmer)
    end

    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      sign_in(current_user)

      expect(fixture_row).to be_a(GogglesDb::Team).and be_valid
      expect(last_affiliations.count).to be_positive
      expect(all_badges_per_type.count).to be_positive
      expect(fixture_swimmers.count).to be_positive
      expect(team_affiliation).to be_a(GogglesDb::TeamAffiliation).and be_valid
      assign(:team, fixture_row)
      assign(:last_affiliations, last_affiliations)
      assign(:team_affiliation, team_affiliation)
      assign(:all_badges_per_type, all_badges_per_type)
      assign(:swimmers, fixture_swimmers)

      render
    end

    it 'includes the section title' do
      expect(parsed_node.at_css('section#team-swimmers-title')).to be_present
      expect(parsed_node.at_css('section#team-swimmers-title h4').text).to include(I18n.t('teams.dashboard.current_swimmers'))
    end

    it 'includes the link to go back to the team details page ("show team", a.k.a. "team dashboard")' do
      expect(parsed_node.at_css('#back-to-dashboard a')).to be_present
      expect(
        parsed_node.at_css('#back-to-dashboard a').attributes['href'].value
      ).to eq(team_show_path(id: fixture_row.id))
    end

    it 'includes the link to go to the top of the page in the footer section' do
      expect(parsed_node.at_css('section#footer a')).to be_present
      expect(parsed_node.at_css('section#footer a').attributes['href'].value).to eq('#top-of-page')
    end

    describe 'within the list of swimmers, for each swimmer,' do
      # Extract all table rows:
      let(:result_table) { Nokogiri::HTML.fragment(rendered).css('#swimmers-list table tbody tr') }

      it 'includes the link to the swimmer\'s profile, name, year of birth, age and category (last and current)' do
        fixture_swimmers.each_with_index do |swimmer, index|
          deco_swimmer = swimmer.decorate
          swimmer_column_data = result_table.css('td.swimmer-name a').at(index)
          expect(swimmer_column_data.attributes['href'].value).to include(swimmer_show_path(id: swimmer.id))
          expect(swimmer_column_data.text).to include(deco_swimmer.display_label)

          badges_column_text = result_table.css('td.swimmer-badges').at(index).text
          expect(badges_column_text).to include(swimmer.year_of_birth.to_s) && include(deco_swimmer.age.to_s) &&
                                        include(deco_swimmer.last_category_type_by_badge&.code) &&
                                        include(deco_swimmer.latest_category_type&.code)
        end
      end
    end
  end
end
