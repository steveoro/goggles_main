# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MRR::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(mrr: parent_result)) }

    let(:parent_result) { FactoryBot.create(:meeting_relay_result_with_swimmers) }

    before { expect(parent_result).to be_a(GogglesDb::MeetingRelayResult).and be_valid }

    it 'renders a table row with 4 cells' do
      expect(subject.css('tbody:first-child tr')).to be_present
      expect(subject.css('tbody:first-child tr').css('td').count).to eq(4)
    end

    context 'when rendering the ranking position in column 1,' do
      let(:ranking_num) { parent_result.rank }
      let(:rendered_result) { subject.css('tbody:first-child tr td')[0].text }

      it_behaves_like('RankingPosComponent rendering a ranking position')
    end

    it 'includes the timing in column 2' do
      expect(subject.css('tbody:first-child tr td')[1].text).to include(parent_result.to_timing.to_s)
    end

    it 'includes the relay\'s team name or relay code' do
      expect(subject.css('tbody:first-child tr td').text).to include(parent_result.team&.editable_name)
        .or include(parent_result.relay_code)
    end

    it 'includes the result score' do
      expect(subject.css('tbody:first-child tr td').text).to include(parent_result.standard_points.to_s)
        .or include(parent_result.meeting_points.to_s)
    end

    # Wrapped under the same, more generic domain to shorten test length
    context 'when rendering a MRR with swimmers/laps,' do
      it 'includes the rotating toggle switch to show the collapsed details sub-page' do
        expect(subject.at_css('.rotating-toggle')).to be_present
      end

      it 'renders all the available laps as individual collapsible rows' do
        expect(subject.css('tr.collapse').count).to eq(parent_result.meeting_relay_swimmers.count)
      end
    end

    it 'does not render the lap edit button (when default options are active)' do
      expect(subject.at_css("a#lap-req-edit-modal-#{parent_result.id}")).not_to be_present
    end

    context 'when rendering a result for which the user can edit laps,' do
      subject { render_inline(described_class.new(mrr: parent_result, lap_edit: true)) }

      it 'renders the lap edit button' do
        expect(subject.at_css("a#lap-req-edit-modal-#{parent_result.id}")).to be_present
      end
    end

    it 'does not render the report mistake button (when default options are active)' do
      expect(subject.at_css("a#type1b1-btn-#{parent_result.id}")).not_to be_present
    end

    context 'when rendering a result for which the user report mistakes,' do
      subject { render_inline(described_class.new(mrr: parent_result, report_mistake: true)) }

      it 'renders the report mistake button' do
        expect(subject.at_css("a#type1b1-btn-#{parent_result.id}")).to be_present
      end
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(mrr: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
