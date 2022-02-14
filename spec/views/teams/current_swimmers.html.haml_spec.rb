# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'teams/current_swimmers.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with valid data and a valid user logged-in,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:current_user) { GogglesDb::User.first(50).sample }
    let(:fixture_team) { GogglesDb::Team.first(50).sample }
    let(:fixture_badges) { GogglesDb::Badge.where(team_id: fixture_team.id).limit(30) }
    let(:fixture_swimmers) do
      GogglesDb::Swimmer.includes(:badges, :gender_type)
                        .joins(:badges, :gender_type)
                        .where(badges: fixture_badges.map(&:id))
                        .distinct
    end

    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      expect(fixture_team).to be_a(GogglesDb::Team).and be_valid
      sign_in(current_user)
      assign(:team, fixture_team)
      assign(:swimmers, fixture_swimmers)
      assign(:latest_badges, fixture_badges)
      render
    end

    it 'includes the section title' do
      expect(parsed_node.at_css('section#team-swimmers-title')).to be_present
      expect(parsed_node.at_css('section#team-swimmers-title h4').text).to eq(I18n.t('teams.dashboard.current_swimmers'))
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
