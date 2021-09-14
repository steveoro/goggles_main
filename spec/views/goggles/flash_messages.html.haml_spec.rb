# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'goggles/_flash_messages.html.haml', type: :view do
  let(:test_message) { FFaker::Lorem.sentence }

  FlashAlertComponent::SUPPORTED_SYMS.each do |flash_sym|
    context "when a flash[:#{flash_sym}] message is set," do
      before do
        expect(test_message).to be_a(String).and be_present
        flash[flash_sym] = test_message
        render
      end

      it 'shows the flash message text in its body' do
        alert_node = Nokogiri::HTML.fragment(rendered).at_css('#flash-messages')
        expect(rendered).to include(ERB::Util.html_escape(test_message))
        expect(alert_node.at_css('.flash-body').text).to eq(ERB::Util.html_escape(test_message))
      end
    end
  end
end
