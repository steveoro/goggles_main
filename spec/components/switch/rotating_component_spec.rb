# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Switch::RotatingComponent, type: :component do
  subject { render_inline(described_class.new(target_id: fixture_dom_id)) }

  let(:fixture_dom_id) { 'test-id-1' }

  it "has the 'switch-sm' wrapper element" do
    expect(subject.at_css('.switch-sm')).to be_present
  end

  it 'renders a button trigger by default' do
    expect(subject.at_css("button#toggle-#{fixture_dom_id}.rotating-toggle")).to be_present
  end

  it "defaults to the 'is-collapsed' class" do
    expect(subject.at_css('.rotating-toggle.is-collapsed')).to be_present
  end

  it 'binds the specified target_id through Stimulus values' do
    trigger = subject.at_css("#toggle-#{fixture_dom_id}")
    expect(trigger.attributes['data-rotating-switch-target-id-value'].value).to eq(fixture_dom_id)
  end

  it 'sets aria-controls to the specified target_id' do
    trigger = subject.at_css("#toggle-#{fixture_dom_id}")
    expect(trigger.attributes['aria-controls'].value).to eq(fixture_dom_id)
  end

  it "allows 'option_classes' to be set on the rotating toggle in the constructor" do
    result = render_inline(described_class.new(target_id: fixture_dom_id, option_classes: 'my-class'))
    expect(result.at_css('.rotating-toggle.my-class')).to be_present
  end

  it 'renders a remote anchor trigger when remote_url is set' do # rubocop:disable RSpec/ExampleLength
    result = render_inline(
      described_class.new(
        target_id: fixture_dom_id,
        remote_url: '/any/remote/path'
      )
    )
    trigger = result.at_css("a#toggle-#{fixture_dom_id}.rotating-toggle")

    expect(trigger).to be_present
    expect(trigger.attributes['href'].value).to eq('/any/remote/path')
    expect(trigger.attributes['data-turbo-stream'].value).to eq('true')
    expect(trigger.attributes['data-controller'].value).to include('loading')
  end

  it 'supports initial expanded state' do
    result = render_inline(described_class.new(target_id: fixture_dom_id, expanded: true))
    trigger = result.at_css("#toggle-#{fixture_dom_id}")

    expect(trigger.classes).to include('is-expanded')
    expect(trigger.attributes['aria-expanded'].value).to eq('true')
  end
end
