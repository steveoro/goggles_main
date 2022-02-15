# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search/_search_results.html.haml', type: :view do
  shared_examples_for 'search result table showing a matching list page' do |result_table_css, base_link_path, matching_name|
    # Verify node content with Nokogiri:
    it 'renders the matching list' do
      result_table = Nokogiri::HTML.fragment(rendered).at_css(result_table_css)
      result_table.map do |result_table_row|
        expect(result_table_row.css('td b a').first.attributes['href'].value).to match(base_link_path)
        expect(result_table_row.css('td b a').first.text).to match(/#{matching_name}/i)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Test empty content (no results):
  context 'when searching for anything without a positive match,' do
    before do
      render(
        partial: 'search_results',
        locals: {
          swimmers: nil,
          teams: nil,
          meetings: nil,
          user_workshops: nil,
          swimming_pools: nil
        }
      )
    end

    it 'doesn\'t include the swipe-wrapper' do
      expect(rendered).not_to include('swipe-wrapper')
    end

    it 'doesn\'t show the pagination controls' do
      expect(rendered).not_to include('page-link')
    end

    %w[swimmer team meeting swimming-pool].each do |dom_id_prefix_for_container|
      it "doesn't show the #{dom_id_prefix_for_container} results table" do
        expect(rendered).not_to include("#{dom_id_prefix_for_container}-results")
      end
    end
  end

  # Test content without pagination:
  context 'when searching for a swimmer name with a few (<= 5) positive matches,' do
    before do
      swimmers = GogglesDb::Swimmer.for_name('John').page(1).per(5)
      expect(swimmers.total_count).to be <= 5
      render(
        partial: 'search_results',
        locals: {
          swimmers: swimmers,
          teams: nil,
          meetings: nil,
          user_workshops: nil,
          swimming_pools: nil
        }
      )
    end

    it_behaves_like(
      'search result table showing a matching list page',
      '#swimmer-results table tbody tr',
      'swimmer\/show\?',
      'John'
    )
    it 'doesn\'t show the pagination controls' do
      expect(rendered).not_to include('page-link')
    end
  end

  # Test paginated content:
  context 'when searching for a swimmer name with positive matches enough for pagination,' do
    before do
      swimmers = GogglesDb::Swimmer.for_name('Anna').page(1).per(5)
      expect(swimmers.total_count).to be > 5
      # Stub out Kaminari completely to avoid mocking each individual view helper: (we don't have to test Kaminari here)
      allow(view).to receive(:paginate)
        .and_return(
          link_to(swimmers.first.complete_name, swimmer_show_path(id: swimmers.first.id), class: 'page-link')
        )
      render(
        partial: 'search_results',
        locals: {
          swimmers: swimmers,
          teams: nil,
          meetings: nil,
          user_workshops: nil,
          swimming_pools: nil
        }
      )
    end

    it_behaves_like(
      'search result table showing a matching list page',
      '#swimmer-results table tbody tr',
      'swimmer\/show\?',
      'Anna'
    )
    it 'shows the pagination controls' do
      expect(rendered).to include('page-link')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Test just the generic paginated content for the remaining entities (to simplify tests)
  context 'when searching for a team name with positive matches enough for pagination,' do
    before do
      teams = GogglesDb::Team.for_name('nuoto').page(1).per(5)
      expect(teams.total_count).to be > 5
      allow(view).to receive(:paginate)
        .and_return(
          link_to(teams.first.editable_name, team_show_path(id: teams.first.id), class: 'page-link')
        )
      render(
        partial: 'search_results',
        locals: {
          swimmers: nil,
          teams: teams,
          meetings: nil,
          user_workshops: nil,
          swimming_pools: nil
        }
      )
    end

    it_behaves_like(
      'search result table showing a matching list page',
      '#team-results table tbody tr',
      'team\/show\?',
      'nuoto'
    )
    it 'shows the pagination controls' do
      expect(rendered).to include('page-link')
    end
  end

  context 'when searching for a meeting description with positive matches enough for pagination,' do
    before do
      meetings = GogglesDb::Meeting.for_name('Desenzano').page(1).per(5)
      expect(meetings.total_count).to be > 5
      allow(view).to receive(:paginate)
        .and_return(
          link_to(meetings.first.description, meeting_show_path(id: meetings.first.id), class: 'page-link')
        )
      render(
        partial: 'search_results',
        locals: {
          swimmers: nil,
          teams: nil,
          meetings: meetings,
          user_workshops: nil,
          swimming_pools: nil
        }
      )
    end

    it_behaves_like(
      'search result table showing a matching list page',
      '#meeting-results table tbody tr',
      'meeting\/show\?',
      'Desenzano'
    )
    it 'shows the pagination controls' do
      expect(rendered).to include('page-link')
    end
  end

  context 'when searching for a user workshop description with positive matches enough for pagination,' do
    before do
      workshops = GogglesDb::UserWorkshop.limit(30).page(1).per(5)
      expect(workshops.total_count).to be > 5
      allow(view).to receive(:paginate)
        .and_return(
          link_to(workshops.first.description, user_workshop_show_path(id: workshops.first.id), class: 'page-link')
        )
      render(
        partial: 'search_results',
        locals: {
          swimmers: nil,
          teams: nil,
          meetings: nil,
          user_workshops: workshops,
          swimming_pools: nil
        }
      )
    end

    it_behaves_like(
      'search result table showing a matching list page',
      '#workshop-results table tbody tr',
      'user_workshop\/show\?',
      'Workshop'
    )
    it 'shows the pagination controls' do
      expect(rendered).to include('page-link')
    end
  end

  context 'when searching for a swimming-pool name with positive matches enough for pagination,' do
    before do
      swimming_pools = GogglesDb::SwimmingPool.for_name('Comunale').page(1).per(5)
      expect(swimming_pools.total_count).to be > 5
      allow(view).to receive(:paginate)
        .and_return(
          link_to(swimming_pools.first.name, swimming_pool_show_path(id: swimming_pools.first.id), class: 'page-link')
        )
      render(
        partial: 'search_results',
        locals: {
          swimmers: nil,
          teams: nil,
          meetings: nil,
          user_workshops: nil,
          swimming_pools: swimming_pools
        }
      )
    end

    it_behaves_like(
      'search result table showing a matching list page',
      '#swimming-pool-results table tbody tr',
      'swimming_pool\/show\?',
      'Comunale'
    )
    it 'shows the pagination controls' do
      expect(rendered).to include('page-link')
    end
  end
end
