# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Switch::XorComponent, type: :component do
  let(:fixture_label1) { 'test-label1' }
  let(:fixture_label2) { 'test-label2' }
  let(:fixture_target1) { 'target-id1' }
  let(:fixture_target2) { 'target-id2' }
  let(:hidden_id) { 'hidden-field-id' }
  let(:custom_css) { 'custom_css' }

  shared_examples_for 'Switch::XorComponent core rendering' do
    it "has a 'switch' wrapper element" do
      node = fragment.at_css('.switch')
      expect(node).to be_present
    end
    it "has the composed 'xor-<target1>-<target2>' as main ID" do
      node = fragment.at("#xor-#{fixture_target1}-#{fixture_target2}")
      expect(node).to be_present
    end
    it "includes both the 'slider' & 'xor' classes at the same level" do
      node = fragment.at("#xor-#{fixture_target1}-#{fixture_target2}")
      expect(node).to be_present
      expect(node['class']).to include('slider').and include('xor')
    end

    it 'renders the label1 text' do
      node = fragment.at("##{fixture_target1}-span-label")
      expect(node).to be_present
      expect(node.text).to include(fixture_label1)
    end
    it 'renders the label2 text' do
      node = fragment.at("##{fixture_target2}-span-label")
      expect(node).to be_present
      expect(node.text).to include(fixture_label2)
    end

    it 'maps the click action of the widget to the correct controller action' do
      node = fragment.at("#xor-#{fixture_target1}-#{fixture_target2}")
      expect(node).to be_present
      expect(node['data-action']).to eq('click->switch#toggleTargets')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when using all the available options,' do
    let(:fragment) do
      Nokogiri::HTML.fragment(
        render_inline(
          described_class.new(
            fixture_label1, fixture_target1,
            fixture_label2, fixture_target2,
            hidden_id: hidden_id, class: custom_css
          )
        ).to_html
      )
    end
    before(:each) { expect(fragment).to be_present }

    it_behaves_like('Switch::XorComponent core rendering')

    it 'includes the hidden field input with the specified DOM ID, mapped as selector field for the controller' do
      node = fragment.at("input##{hidden_id}")
      expect(node).to be_present
      expect(node['type']).to eq('hidden')
      expect(node['data-switch-target']).to eq('selector')
    end
    it 'uses the specified custom CSS classes on the widget' do
      node = fragment.at("#xor-#{fixture_target1}-#{fixture_target2}")
      expect(node).to be_present
      expect(node['class']).to include(custom_css)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when skipping the hidden_id field option,' do
    let(:fragment) do
      Nokogiri::HTML.fragment(
        render_inline(
          described_class.new(
            fixture_label1, fixture_target1,
            fixture_label2, fixture_target2
          )
        ).to_html
      )
    end
    before(:each) { expect(fragment).to be_present }

    it_behaves_like('Switch::XorComponent core rendering')

    it 'does not render the hidden input field' do
      node = fragment.at('input[type="hidden"]')
      expect(node).not_to be_present
    end
  end
end
