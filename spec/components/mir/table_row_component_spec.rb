# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MIR::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(mir: fixture_mir)) }

    let(:fixture_mir) { FactoryBot.create(:meeting_individual_result_with_laps) }

    before { expect(fixture_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid }

    it 'renders a table row with 4 cells' do
      expect(subject.css('tbody:first-child tr')).to be_present
      expect(subject.css('tbody:first-child tr').css('td').count).to eq(4)
    end

    context 'when rendering the ranking position in column 1,' do
      let(:ranking_num) { fixture_mir.rank }
      let(:rendered_result) { subject.css('tbody:first-child tr td')[0].text }

      it_behaves_like('RankingPosComponent rendering a ranking position')
    end

    it 'includes the timing in column 2' do
      expect(subject.css('tbody:first-child tr td')[1].text).to include(fixture_mir.to_timing.to_s)
    end

    it 'includes the swimmer\'s complete name' do
      expect(subject.css('tbody:first-child tr td').text).to include(fixture_mir.swimmer&.complete_name)
    end

    it 'includes the swimmer\'s team name' do
      expect(subject.css('tbody:first-child tr td').text).to include(fixture_mir.team&.editable_name)
    end

    it 'includes the swimmer\'s year of birth' do
      expect(subject.css('tbody:first-child tr td').text).to include(fixture_mir.swimmer&.year_of_birth.to_s)
    end

    it 'includes the result score' do
      expect(subject.css('tbody:first-child tr td').text).to include(fixture_mir.standard_points.to_s)
        .or include(fixture_mir.meeting_points.to_s)
    end

    # Wrapped under the same, more generic domain to shorten test length
    context 'when rendering a MIR with laps,' do
      it 'includes the rotating toggle switch to show the collapsed details sub-page' do
        expect(subject.at_css('.rotating-toggle')).to be_present
      end

      it 'renders all the available laps as individual collapsible rows' do
        expect(subject.css('tr.collapse').count).to eq(fixture_mir.laps.count)
      end
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(mir: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
