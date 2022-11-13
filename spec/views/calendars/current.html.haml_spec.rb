# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'calendars/current.html.haml', type: :view do
  include_context('calendar_grid rendered with valid data')

  context 'when the current user does not manage any available team,' do
    before do
      assign(:managed_teams, [])
      CalendarsGrid.managed_teams = []
      grid = CalendarsGrid.new do |scope|
        scope.where(season_id: fixture_season_id).page(1).per(8)
      end
      assign(:grid, grid)
      render
    end

    it 'includes the section title' do
      expect(parsed_node.at_css('section#current-calendars-title')).to be_present
      expect(parsed_node.at_css('section#current-calendars-title h4').text.strip).to include(I18n.t('calendars.dashboard.title'))
    end

    it 'includes the datagrid section with the filtering form' do
      expect(parsed_node.at_css('section#data-grid form')).to be_present
    end

    it 'includes the datagrid filtering show button in the top row' do
      expect(parsed_node.at_css('section#data-grid .row#datagrid-top-row #filter-show-btn button')).to be_present
    end

    it_behaves_like('calendars/current.html.haml rendered with valid data')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the current user is also a team manager for the displayed season,' do
    before do
      # Given that we force both the domain and the managed teams with assigns, it doesn't matter
      # if the current user has actually any ManagedAffiation rows for the displayed season rows
      managed_teams = GogglesDb::Team.first(100).sample(2)
      assign(:managed_teams, managed_teams)
      CalendarsGrid.managed_teams = managed_teams
      grid = CalendarsGrid.new do |scope|
        scope.where(season_id: fixture_season_id).page(1).per(8)
      end
      assign(:grid, grid)
      render
    end

    it 'includes the section title' do
      expect(parsed_node.at_css('section#current-calendars-title')).to be_present
      expect(parsed_node.at_css('section#current-calendars-title h4').text.strip).to include(I18n.t('calendars.dashboard.title'))
    end

    it 'includes the datagrid section with the filtering form' do
      expect(parsed_node.at_css('section#data-grid form')).to be_present
    end

    it 'includes the datagrid filtering show button in the top row' do
      expect(parsed_node.at_css('section#data-grid .row#datagrid-top-row #filter-show-btn button')).to be_present
    end

    it 'renders a team-star widget for each row in the grid' do
      expect(parsed_node.at_css('section#data-grid table.table tbody tr')).to be_present
      grid_domain.each do |calendar_row|
        # This should always work, even when the meeting_id is not set:
        expect(parsed_node.css("section#data-grid table.table tbody tr td span#team-star-#{calendar_row.meeting_id}")).to be_present
      end
    end

    it_behaves_like('calendars/current.html.haml rendered with valid data')
  end
  #-- -------------------------------------------------------------------------
  #++
end
