# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Switch::RotatingComponent, type: :component do
  let(:fixture_dom_id) { 'test-id-1' }
  subject { render_inline(described_class.new(target_id: fixture_dom_id)) }

  it "has the 'switch-sm' wrapper element" do
    expect(subject.at_css('.switch-sm')).to be_present
  end
  it "defaults to the 'collapsed' class" do
    expect(subject.at_css('.rotating-toggle.collapsed')).to be_present
  end
  it 'links to the specified DOM target_id' do
    expect(subject.at_css('.rotating-toggle')['href']).to eq("##{fixture_dom_id}")
  end
end
