# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'goggles/_flash_messages.html.haml', type: :view do
  let(:test_message) { FFaker::Lorem.sentence }
  before(:each)      { expect(test_message).to be_a(String).and be_present }

  shared_examples_for 'flash_messages generic features' do |parent_node_id|
    let(:alert_node) { Nokogiri::HTML.fragment(rendered).at_css(parent_node_id) }
    before(:each)    { expect(alert_node).to be_a(Nokogiri::XML::Element) }

    it 'is an alert box' do
      expect(alert_node.classes).to include('alert')
    end
    it 'shows the flash message text in its body' do
      expect(rendered).to include(ERB::Util.html_escape(test_message))
      expect(alert_node.at_css('.flash-body').text).to eq(ERB::Util.html_escape(test_message))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when a flash[:info] message is set,' do
    before(:each) do
      flash[:info] = test_message
      render
    end
    it_behaves_like('flash_messages generic features', '#flash-info-msg')
  end

  context 'when a flash[:warning] message is set,' do
    before(:each) do
      flash[:warning] = test_message
      render
    end
    it_behaves_like('flash_messages generic features', '#flash-warning-msg')
  end

  context 'when a flash[:alert] message is set,' do
    before(:each) do
      flash[:alert] = test_message
      render
    end
    it_behaves_like('flash_messages generic features', '#flash-alert-msg')
  end

  context 'when a flash[:error] message is set,' do
    before(:each) do
      flash[:error] = test_message
      render
    end
    it_behaves_like('flash_messages generic features', '#flash-error-msg')
  end
end
