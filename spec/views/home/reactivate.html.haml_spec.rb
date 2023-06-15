# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/reactivate.html.haml' do
  # Test basic/required content:
  context 'when rendering with data,' do
    before { render }

    it 'shows the #reactivate-account-box section with the title' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#reactivate-account-box')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('devise.customizations.reactivation.title'))
    end

    it 'includes the email form' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#reactivate-account-box form#new_user')
      expect(node).to be_present
    end
  end
end
