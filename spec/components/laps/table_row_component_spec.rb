# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Laps::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_mir) { FactoryBot.create(:meeting_individual_result_with_laps) }
    let(:fixture_lap) { fixture_mir.laps.sample }
    before(:each) do
      expect(fixture_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
      expect(fixture_lap).to be_a(GogglesDb::Lap).and be_valid
      expect(fixture_lap.meeting_individual_result_id).to eq(fixture_mir.id)
    end

    subject { render_inline(described_class.new(lap: fixture_lap)).to_html }

    it 'renders a collapsed table row with 2 cells' do
      tr_node = Nokogiri::HTML.fragment(subject).css('tr.collapse')
      expect(tr_node).to be_present
      expect(tr_node.css('td').count).to eq(2)
    end
    it 'includes the length in meters' do
      td_node = Nokogiri::HTML.fragment(subject).at_css('tr.collapse td.text-muted')
      expect(td_node.text).to include(fixture_lap.length_in_meters&.to_s)
    end
    it 'includes the lap timing' do
      td_node = Nokogiri::HTML.fragment(subject).at_css('tr.collapse td.text-left')
      expect(td_node.text).to include(fixture_lap.to_timing&.to_s)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(lap: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
