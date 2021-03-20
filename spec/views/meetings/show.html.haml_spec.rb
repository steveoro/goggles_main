# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/show.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with data,' do
    let(:fixture_row) { GogglesDb::Meeting.first(100).sample }
    before(:each) do
      expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
      @meeting = fixture_row
      render
    end

    it 'shows the description with its edition label' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#full-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.description).and include(fixture_row.edition_label)
    end
    it 'shows the entry deadline' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#entry-deadline')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.entry_deadline.to_s)
    end
    it 'shows the meeting date' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#header-date')
      expect(node).to be_present
    end
    it 'shows various contact information' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#e-mail')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#contact-name')).to be_present
    end
    it 'shows the basic meeting boolean flags' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#warm-up-pool')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#allows-under25')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#confirmed')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
