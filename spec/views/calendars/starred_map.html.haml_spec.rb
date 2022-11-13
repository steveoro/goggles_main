# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'calendars/starred_map.html.haml', type: :view do
  # Test basic/required content:
  subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

  let(:current_user) { GogglesDb::User.find([1, 2, 4].sample) }
  let(:fixture_season_id) { [162, 172].sample }
  let(:grid_domain) do
    GogglesDb::Calendar.includes(
      meeting: [
        :swimming_pools,
        { meeting_sessions: [:swimming_pool, { meeting_events: :event_type }] }
      ]
    )
                       .where(season_id: fixture_season_id).distinct
                       .order(scheduled_date: :asc)
                       .first(grid_rows)
  end

  context 'when rendered with valid data,' do
    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      expect(current_user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
      sign_in(current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(current_user)
      # No point in having actual rendered map markers as we're not testing the
      # JS library here; an empty array is enough for both the map places and the user teams:
      assign(:map_places, [])
      assign(:user_teams, [])
      assign(:last_seasons_ids, [fixture_season_id])
      render
    end

    it 'includes the section title' do
      expect(parsed_node.at_css('section#calendars-map-title')).to be_present
      expect(parsed_node.at_css('section#calendars-map-title h4').text.strip).to include(I18n.t('calendars.dashboard.starred_title'))
    end

    it 'includes the link to go back to the dashboard' do
      expect(parsed_node.at_css('a#back-to-parent')).to be_present
      expect(parsed_node.at_css('a#back-to-parent').attributes['href'].value).to eq(home_dashboard_path)
    end

    it 'includes the calendar nav tab with the link to go back to the calendar list' do
      expect(parsed_node.at_css('section#calendars-map-navs ul.nav.nav-tabs')).to be_present
      expect(parsed_node.at_css('section#calendars-map-navs ul.nav.nav-tabs li.nav-item a')).to be_present
      expect(parsed_node.at_css('section#calendars-map-navs ul.nav.nav-tabs li.nav-item a').attributes['href'].value)
        .to eq(calendars_starred_path)
    end

    it 'includes the actual calendars map section with the leaflet map' do
      expect(parsed_node.at_css('section#calendars-map #leaflet-map')).to be_present
    end

    it 'includes a footer section' do
      expect(parsed_node.at_css('section#footer')).to be_present
    end
  end
end
