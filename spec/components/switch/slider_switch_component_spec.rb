# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Switch::SliderComponent, type: :component do
  subject { render_inline(described_class.new(target_id: fixture_dom_id)) }

  let(:fixture_dom_id) { 'test-id-1' }

  it "has the 'switch' wrapper element" do
    expect(subject.at_css('.switch')).to be_present
  end

  it "defaults to the 'collapsed' class" do
    expect(subject.at_css('.slider.collapsed')).to be_present
  end

  it 'links to the specified DOM target_id' do
    expect(subject.at_css('.slider')['href']).to eq("##{fixture_dom_id}")
  end
end
