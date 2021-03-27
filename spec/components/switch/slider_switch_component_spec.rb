# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Switch::SliderComponent, type: :component do
  let(:fixture_dom_id) { 'test-id-1' }
  subject do
    render_inline(
      described_class.new(target_id: fixture_dom_id)
    ).to_html
  end

  it "has the 'switch' wrapper element" do
    wrapper = Nokogiri::HTML.fragment(subject).at_css('.switch')
    expect(wrapper).to be_present
  end
  it "defaults to the 'collapsed' class" do
    widget = Nokogiri::HTML.fragment(subject).at_css('.slider.collapsed')
    expect(widget).to be_present
  end
  it 'links to the specified DOM target_id' do
    widget = Nokogiri::HTML.fragment(subject).at_css('.slider')
    expect(widget['href']).to eq("##{fixture_dom_id}")
  end
end
