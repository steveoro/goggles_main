# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MRR::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_mrr) { FactoryBot.create(:meeting_relay_result_with_swimmers) }
    before(:each) { expect(fixture_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid }

    subject { render_inline(described_class.new(mrr: fixture_mrr)).to_html }

    it 'renders a table row with 4 cells' do
      tr_node = Nokogiri::HTML.fragment(subject).css('tbody:first-child tr')
      expect(tr_node).to be_present
      expect(tr_node.css('td').count).to eq(4)
    end

    context 'when rendering the ranking position in column 1,' do
      let(:ranking_num) { fixture_mrr.rank }
      let(:rendered_result) { Nokogiri::HTML.fragment(subject).css('tbody:first-child tr td')[0].text }
      it_behaves_like('RankingPosComponent rendering a ranking position')
    end

    it 'includes the timing in column 2' do
      tr_node = Nokogiri::HTML.fragment(subject).css('tbody:first-child tr td')[1]
      expect(tr_node.text).to include(fixture_mrr.to_timing.to_s)
    end
    it 'includes the relay\'s team name or relay code' do
      tr_node = Nokogiri::HTML.fragment(subject).css('tbody:first-child tr td')
      expect(tr_node.text).to include(fixture_mrr.team&.editable_name)
        .or include(fixture_mrr.relay_code)
    end
    it 'includes the result score' do
      tr_node = Nokogiri::HTML.fragment(subject).css('tbody:first-child tr td')
      expect(tr_node.text).to include(fixture_mrr.standard_points.to_s)
        .or include(fixture_mrr.meeting_points.to_s)
    end

    # Wrapped under the same, more generic domain to shorten test length
    context 'when rendering a MRR with swimmers/laps,' do
      it 'includes the rotating toggle switch to show the collapsed details sub-page' do
        node = Nokogiri::HTML.fragment(subject).at_css('.rotating-toggle')
        expect(node).to be_present
      end
      # TODO
      xit 'renders all the available laps as individual collapsible rows' do
        node = Nokogiri::HTML.fragment(subject).css('tr.collapse')
        expect(node.count).to eq(fixture_mrr.meeting_relay_swimmers.count)
      end
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(mrr: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
