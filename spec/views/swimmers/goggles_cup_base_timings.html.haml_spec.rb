# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'swimmers/goggles_cup_base_timings.html.haml' do
  let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }

  context 'when rendering with data,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:base_timings) do
      GogglesDb::GogglesCup3yBaseTimings.includes(:event_type, :pool_type, :season, :meeting,
                                                  season: [:federation_type, { season_type: :federation_type }])
                                        .where(swimmer_id: fixture_row.id)
                                        .limit(5)
                                        .to_a
    end

    before do
      expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid

      assign(:swimmer, fixture_row)
      assign(:base_timings, base_timings)
      render
    end

    it 'shows the page title with a link back to the swimmer radiography' do
      node = subject.at_css('section#swimmer-goggles-cup-base-timings-title')
      expect(node).to be_present
      expect(node.at_css('h4 a#back-to-parent')).to be_present
      expect(node.at_css('h4 a#back-to-parent').attributes['href'].value).to eq(swimmer_show_path(fixture_row))
    end

    it 'includes the swimmer complete name' do
      node = subject.at_css('section#swimmer-goggles-cup-base-timings #swimmer-name')
      expect(node).to be_present
      expect(node.text).to eq(fixture_row.complete_name)
    end

    it 'renders the base timings table' do
      table = subject.at_css('section#swimmer-goggles-cup-base-timings table')
      expect(table).to be_present
    end

    it 'shows the Goggles Cup base timings title' do
      expect(subject.text).to include(I18n.t('swimmers.radiography.goggles_cup_base_timings_title'))
    end

    it 'shows the info note explaining Goggles Cup scoring' do
      note = subject.at_css('#best-results-info-note')
      expect(note).to be_present
      expect(note.text).to include(I18n.t('swimmers.radiography.goggles_cup_base_timings_note'))
    end

    it 'renders a table row for each base timing' do
      rows = subject.css('section#swimmer-goggles-cup-base-timings table tbody tr')
      expect(rows.count).to eq(base_timings.count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when rendering with no base timings,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before do
      assign(:swimmer, fixture_row)
      assign(:base_timings, [])
      render
    end

    it 'still renders the page structure with an empty table body' do
      expect(subject.at_css('section#swimmer-goggles-cup-base-timings-title')).to be_present
      expect(subject.at_css('section#swimmer-goggles-cup-base-timings #swimmer-name')).to be_present
      expect(subject.at_css('section#swimmer-goggles-cup-base-timings table')).to be_present
      expect(subject.at_css('#best-results-info-note')).to be_present
      expect(subject.css('section#swimmer-goggles-cup-base-timings table tbody tr')).to be_empty
    end
  end
end
