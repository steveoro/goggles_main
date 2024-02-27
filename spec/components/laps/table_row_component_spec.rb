# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Laps::TableRowComponent, type: :component do
  # Select an abstract lap for the parent result, so that we're sure we have existing
  # lap rows (although not required, makes the test more complete)
  let(:parent_result) do
    lap = [
      GogglesDb::Lap.last(500).sample,
      GogglesDb::UserLap.last(500).sample
    ].sample
    lap.parent_result
  end

  let(:fixture_lap) { parent_result.laps.sample }

  before do
    expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid
    expect(parent_result.laps.count).to be_positive
    expect(fixture_lap).to be_an(GogglesDb::AbstractLap).and be_valid
    expect(fixture_lap.parent_result_id).to eq(parent_result.id)
  end

  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(lap: fixture_lap)) }

    it 'renders a collapsed table row with 2 cells' do
      expect(subject.css('tr.collapse')).to be_present
      expect(subject.css('tr.collapse').css('td').count).to eq(2)
    end

    it 'includes the length in meters' do
      expect(subject.at_css('tr.collapse td .length-in-meters').text).to include(fixture_lap.length_in_meters&.to_s)
    end

    it 'includes both the lap delta timing and the timing from start' do
      expect(subject.at_css('tr.collapse td .delta-timing').text).to include("#{fixture_lap.to_timing} Δ")
      expect(subject.at_css('tr.collapse td .delta-timing').text).to include("#{fixture_lap.timing_from_start} ⏱")
    end
  end

  context 'with the same valid parameter and also with collapsed: false,' do
    subject { render_inline(described_class.new(lap: fixture_lap, collapsed: false)) }

    it 'renders the same table row with 2 cells but NOT collapsed' do
      expect(subject.css('tr')).to be_present
      expect(subject.css('tr').css('td').count).to eq(2)
      expect(subject.css('tr.collapse')).not_to be_present
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(lap: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
