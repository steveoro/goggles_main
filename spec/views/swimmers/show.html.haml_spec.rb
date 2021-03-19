# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'swimmers/show.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with data,' do
    let(:fixture_row) { GogglesDb::Swimmer.first(100).sample }
    before(:each) do
      expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid
      @swimmer = fixture_row
      render
    end

    it 'shows the name' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#full-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.first_name)
      expect(node.text).to include(fixture_row.last_name)
    end
    it 'shows the year of birth' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#year-of-birth')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.year_of_birth.to_s)
    end
    it 'shows the current category code' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#curr-cat-code')).to be_present
    end
    it 'shows the last category code' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#last-cat-code')).to be_present
    end
    it 'shows the links to the affiliated teams' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#team-links')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
