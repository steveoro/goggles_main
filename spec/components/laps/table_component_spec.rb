# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Laps::TableComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(laps: parent_result.laps)) }

    # Select an abstract lap for the parent result, so that we're sure we have existing
    # lap rows (although not required, makes the test more complete)
    let(:parent_result) do
      lap = [
        GogglesDb::Lap.last(500).sample,
        GogglesDb::UserLap.last(500).sample
      ].sample
      lap.parent_result
    end

    before do
      expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid
      expect(parent_result.laps.count).to be_positive
    end

    it 'renders a table body' do
      expect(subject.css('tbody')).to be_present
    end

    it 'renders as many table rows as the laps specified + 1 additional row (for the end result)' do
      expect(subject.css('tr').count).to eq(parent_result.laps.count + 1)
    end

    describe 'when rendering the lap rows,' do
      it 'includes each lap details, respecting the ordering' do
        parent_result.laps.by_distance.each_with_index do |lap, index|
          dom_row = subject.css('tr')[index]
          expect(dom_row.css('td').first.text).to include(lap.length_in_meters.to_s)
          expect(dom_row.css('td').last.text).to include(lap.to_timing.to_s)
          expect(dom_row.css('td').last.text).to include(lap.timing_from_start.to_s)
        end
      end

      it 'renders an additional final row with the ending result' do
        last_dom_row = subject.css('tr').last
        last_lap = parent_result.laps.by_distance.last
        last_delta_timing = parent_result.to_timing - last_lap.timing_from_start
        expect(last_dom_row.css('td').first.text).to include(parent_result.event_type.length_in_meters.to_s)
        # If laps come from factories, these will be random in timing and delta could
        # be something like "-1d 23h ..." with the days & hours part omitted from the
        # output. So we just check from the minutes downward:
        expect(last_dom_row.css('td').last.text).to include(last_delta_timing.to_s.split('h ').last)
        expect(last_dom_row.css('td').last.text).to include(parent_result.to_timing.to_s)
      end
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(laps: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
