# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelayLaps::TableRowComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_mrr) { FactoryBot.create(:meeting_relay_result_with_swimmers) }
    let(:fixture_lap) { fixture_mrr.meeting_relay_swimmers.sample }
    before(:each) do
      expect(fixture_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
      expect(fixture_mrr.meeting_relay_swimmers.count).to be_positive
      expect(fixture_lap).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
    end

    subject { render_inline(described_class.new(relay_swimmer: fixture_lap)).to_html }

    it 'renders a collapsed table row with 2 cells' do
      tr_node = Nokogiri::HTML.fragment(subject).css('tr.collapse')
      expect(tr_node).to be_present
      expect(tr_node.css('td').count).to eq(2)
    end
    it 'includes the lap swimmer name' do
      td_node = Nokogiri::HTML.fragment(subject).css('tr.collapse td')
      expect(td_node.text).to include(fixture_lap.swimmer.complete_name)
    end
    it 'includes the lap swimmer year of birth' do
      td_node = Nokogiri::HTML.fragment(subject).css('tr.collapse td')
      expect(td_node.text).to include(fixture_lap.swimmer.year_of_birth.to_s)
    end
    it 'includes the lap timing' do
      td_node = Nokogiri::HTML.fragment(subject).css('tr.collapse td.text-left')
      expect(td_node.text).to include(fixture_lap.to_timing&.to_s)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(relay_swimmer: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
