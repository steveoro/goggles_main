# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelayLaps::TableComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(relay_swimmers: parent_result.meeting_relay_swimmers)) }

    let(:parent_result) { FactoryBot.create(:meeting_relay_result_with_swimmers) }

    before do
      expect(parent_result).to be_a(GogglesDb::MeetingRelayResult).and be_valid
      expect(parent_result.meeting_relay_swimmers.count).to be_positive
    end

    it 'renders a table body with collapse class' do
      tbody = subject.css('tbody').first
      expect(tbody).to be_present
      expect(tbody.classes).to include('collapse')
    end

    it 'renders as many table rows as the laps specified' do
      expect(subject.css('tr').count).to eq(parent_result.meeting_relay_swimmers.count)
    end

    it 'does not add collapse class or duplicate IDs to individual rows' do
      subject.css('tr').each do |row|
        expect(row.classes).not_to include('collapse')
        expect(row['id']).to be_nil
      end
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(relay_swimmers: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
