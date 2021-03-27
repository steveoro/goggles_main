# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Laps::TableComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_mir) { FactoryBot.create(:meeting_individual_result_with_laps) }
    before(:each) do
      expect(fixture_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
      expect(fixture_mir.laps.count).to be_positive
    end

    subject { render_inline(described_class.new(laps: fixture_mir.laps)).to_html }

    it 'renders a table body' do
      node = Nokogiri::HTML.fragment(subject).css('tbody')
      expect(node).to be_present
    end
    it 'renders as many table rows as the laps specified' do
      node = Nokogiri::HTML.fragment(subject).css('tr')
      expect(node.count).to eq(fixture_mir.laps.count)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(laps: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
