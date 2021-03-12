# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'goggles/_flash_messages.html.haml', type: :view do
  let(:test_message) { FFaker::Lorem.sentence }
  before(:each)      { expect(test_message).to be_a(String).and be_present }

  shared_examples_for 'flash_messages generic features' do
    let(:alert_node) { Nokogiri::HTML.fragment(rendered).at_css('#flash-content-body') }
    before(:each)    { expect(alert_node).to be_a(Nokogiri::XML::Element) }

    it 'is a modal box' do
      expect(alert_node.classes).to include('modal-body')
    end
    it 'shows the flash message text in its body' do
      expect(rendered).to include(ERB::Util.html_escape(test_message))
      expect(alert_node.at_css('.flash-body').text).to eq(ERB::Util.html_escape(test_message))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  %i[info warning alert error].each do |flash_sym|
    context "when a flash[#{flash_sym}] message is set," do
      before(:each) do
        flash[flash_sym] = test_message
        render
      end
      it_behaves_like('flash_messages generic features')
    end
  end
end
