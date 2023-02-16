# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MIR::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(mir: parent_result)) }

    # Select an abstract lap for the parent result, so that we're sure we have existing
    # lap rows (although not required, makes the test more complete)
    let(:parent_result) do
      lap = [GogglesDb::Lap.last(500).sample, GogglesDb::UserLap.last(500).sample].sample
      lap.parent_result
    end

    before do
      expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid
      expect(parent_result.laps.count).to be_positive
    end

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

    it 'includes the swimmer\'s complete name' do
      expect(subject.css('tbody:first-child tr td').text).to include(parent_result.swimmer&.complete_name)
    end

    it 'includes the swimmer\'s team name when available' do
      expect(subject.css('tbody:first-child tr td').text).to include(parent_result.team&.editable_name) if parent_result.respond_to?(:team_id)
    end

    it 'includes the swimmer\'s year of birth' do
      expect(subject.css('tbody:first-child tr td').text).to include(parent_result.swimmer&.year_of_birth.to_s)
    end

    it 'includes the result score' do
      expect(subject.css('tbody:first-child tr td').text).to include(parent_result.standard_points.to_s)
        .or include(parent_result.meeting_points.to_s)
    end

    # Wrapped under the same, more generic domain to shorten test length
    context 'when rendering a result with laps,' do
      it 'includes the rotating toggle switch to show the collapsed details sub-page' do
        expect(subject.at_css('.rotating-toggle')).to be_present
      end

      it 'renders all the available laps as individual collapsible rows plus the ending result' do
        expect(subject.css('tr.collapse').count).to eq(parent_result.laps.count + 1)
      end
    end

    it 'does not render the lap edit button (when default options are active)' do
      expect(subject.at_css("a#lap-req-edit-modal-#{parent_result.id}")).not_to be_present
    end

    context 'when rendering a result for which the user can edit laps,' do
      subject { render_inline(described_class.new(mir: parent_result, lap_edit: true)) }

      it 'renders the lap edit button' do
        expect(subject.at_css("a#lap-req-edit-modal-#{parent_result.id}")).to be_present
      end
    end

    it 'does not render the report mistake button (when default options are active)' do
      expect(subject.at_css("a#type1b1-btn-#{parent_result.id}")).not_to be_present
    end

    context 'when rendering a result for which the user report mistakes,' do
      subject { render_inline(described_class.new(mir: parent_result, report_mistake: true)) }

      it 'renders the report mistake button' do
        expect(subject.at_css("a#type1b1-btn-#{parent_result.id}")).to be_present
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an invalid parameter,' do
    subject do
      render_inline(
        described_class.new(mir: ['not-a-parent-result', nil, GogglesDb::User.first(10).sample].sample)
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
