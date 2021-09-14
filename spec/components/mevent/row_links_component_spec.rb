# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mevent::RowLinksComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(meeting_events: fixture_meeting.meeting_events)) }

    let(:fixture_meeting) do
      GogglesDb::Meeting.joins(:meeting_events)
                        .includes(:meeting_events)
                        .first(100)
                        .sample
    end

    before do
      expect(fixture_meeting).to be_a(GogglesDb::Meeting).and be_valid
      expect(fixture_meeting.meeting_events.count).to be_positive
    end

    it 'renders a table header with a single table row' do
      expect(subject.css('thead tr')).to be_present
    end

    it 'renders a table row spanning 4 columns' do
      expect(subject.css('thead tr th.mevent-links').first[:colspan]).to eq('4')
    end

    it 'renders as many links to events as the specified events' do
      # Subtract from total count the link on top of the page:
      expect(subject.css('thead tr th.mevent-links').css('a').count - 1).to eq(
        fixture_meeting.meeting_events.count
      )
    end

    it 'includes as last link the top of the page' do
      expect(subject.css('thead tr th.mevent-links').css('a').last[:href]).to eq('#top-of-page')
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_events: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
