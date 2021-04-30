# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/contact_us.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with data,' do
    before(:each) { render }

    it 'shows the #contact-us-box section with the title' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#contact-us-box')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('contact_us.title'))
    end

    it 'includes the message form' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#frm-contact-us')
      expect(node).to be_present
    end
  end
end
