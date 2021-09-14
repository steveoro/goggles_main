# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MRR::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(mrr: fixture_mrr)) }

    let(:fixture_mrr) { FactoryBot.create(:meeting_relay_result_with_swimmers) }

    before { expect(fixture_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid }

    it 'renders a table row with 4 cells' do
      expect(subject.css('tbody:first-child tr')).to be_present
      expect(subject.css('tbody:first-child tr').css('td').count).to eq(4)
    end

    context 'when rendering the ranking position in column 1,' do
      let(:ranking_num) { fixture_mrr.rank }
      let(:rendered_result) { subject.css('tbody:first-child tr td')[0].text }

      it_behaves_like('RankingPosComponent rendering a ranking position')
    end

    it 'includes the timing in column 2' do
      expect(subject.css('tbody:first-child tr td')[1].text).to include(fixture_mrr.to_timing.to_s)
    end

    it 'includes the relay\'s team name or relay code' do
      expect(subject.css('tbody:first-child tr td').text).to include(fixture_mrr.team&.editable_name)
        .or include(fixture_mrr.relay_code)
    end

    it 'includes the result score' do
      expect(subject.css('tbody:first-child tr td').text).to include(fixture_mrr.standard_points.to_s)
        .or include(fixture_mrr.meeting_points.to_s)
    end

    # Wrapped under the same, more generic domain to shorten test length
    context 'when rendering a MRR with swimmers/laps,' do
      it 'includes the rotating toggle switch to show the collapsed details sub-page' do
        expect(subject.at_css('.rotating-toggle')).to be_present
      end

      it 'renders all the available laps as individual collapsible rows' do
        expect(subject.css('tr.collapse').count).to eq(fixture_mrr.meeting_relay_swimmers.count)
      end
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(mrr: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
