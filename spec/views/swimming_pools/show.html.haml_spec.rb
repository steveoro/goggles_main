# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'swimming_pools/show.html.haml' do
  # Test basic/required content:
  context 'when rendering with data,' do
    let(:fixture_row) { GogglesDb::SwimmingPool.first(100).sample }

    before do
      expect(fixture_row).to be_a(GogglesDb::SwimmingPool).and be_valid
      @swimming_pool = fixture_row
      render
    end

    it 'shows the name' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#full-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.name)
    end

    it 'shows the address' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#address')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.address)
      expect(node.text).to include(fixture_row.city&.name)
    end

    it 'shows the nick-name' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#nick-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.nick_name)
    end

    it 'shows the pool type' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#pool-type')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.lanes_number.to_s)
      expect(node.text).to include(fixture_row.pool_type.label)
    end

    it 'shows various contact information' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#fax-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#e-mail')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#contact-name')).to be_present
    end

    it 'shows the multiple pools flag' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#multiple-pools')).to be_present
    end

    it 'shows the garden presence flag' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#garden-presence')).to be_present
    end

    it 'shows the bar presence flag' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#bar-presence')).to be_present
    end

    it 'shows the restaurant presence flag' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#restaurant-presence')).to be_present
    end

    it 'shows the gym presence flag' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#gym-presence')).to be_present
    end

    it 'shows the children area flag' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#children-area-presence')).to be_present
    end

    it 'shows the locker cabinet type' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#locker-cabinet-type')).to be_present
    end

    it 'shows the shower type' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#shower-type')).to be_present
    end

    it 'shows the hair dryer type' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#hair-dryer-type')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
