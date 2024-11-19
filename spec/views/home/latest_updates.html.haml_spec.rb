# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/latest_updates.html.haml' do
  # Test basic/required content:
  context 'when rendering with data,' do
    before { render }

    it 'always shows the #updated-calendars section (even without recent updates)' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#updated-calendars')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('calendars.updated_calendars.title', total: nil))
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
