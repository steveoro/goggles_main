# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mevent::RowTitleComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(meeting_event: fixture_row)) }

    let(:fixture_row) { GogglesDb::MeetingEvent.first(100).sample }

    before { expect(fixture_row).to be_a(GogglesDb::MeetingEvent).and be_valid }

    it 'shows the meeting event label' do
      expect(subject.css('h4')).to be_present
      expect(subject.css('h4').text).to include(fixture_row.event_type.long_label.to_s)
    end

    it 'renders a linkable table row' do
      expect(subject.at_css('tr')).to be_present
      expect(subject.at_css('tr')[:id]).to eq("mevent-#{fixture_row.id}")
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_event: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
