# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'teams/show.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with data,' do
    let(:fixture_row) { GogglesDb::Team.first(50).sample }
    before(:each) do
      expect(fixture_row).to be_a(GogglesDb::Team).and be_valid
      @team = fixture_row
      render
    end

    it 'shows the name' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#full-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.name).or include(fixture_row.editable_name)
    end
    it 'shows the address' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#address')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.address)
      expect(node.text).to include(fixture_row.city&.name)
    end
    it 'shows the home_page_url' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#homepage')
      expect(node).to be_present
    end
    it 'shows various contact information' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#contact-name')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-mobile')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#fax-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#e-mail')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
