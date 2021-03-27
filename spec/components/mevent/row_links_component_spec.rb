# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mevent::RowLinksComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_meeting) do
      GogglesDb::Meeting.joins(:meeting_events)
                        .includes(:meeting_events)
                        .first(100)
                        .sample
    end
    before(:each) do
      expect(fixture_meeting).to be_a(GogglesDb::Meeting).and be_valid
      expect(fixture_meeting.meeting_events.count).to be_positive
    end

    subject { render_inline(described_class.new(meeting_events: fixture_meeting.meeting_events)).to_html }

    it 'renders a table header with a single table row' do
      node = Nokogiri::HTML.fragment(subject).css('thead tr')
      expect(node).to be_present
    end
    it 'renders a table row spanning 4 columns' do
      node = Nokogiri::HTML.fragment(subject).css('thead tr th.mevent-links')
      expect(node.first[:colspan]).to eq('4')
    end
    it 'renders as many links to events as the specified events' do
      node = Nokogiri::HTML.fragment(subject).css('thead tr th.mevent-links')
      # Subtract the link to the top of page:
      expect(node.css('a').count - 1).to eq(fixture_meeting.meeting_events.count)
    end
    it 'includes as last link the top of the page' do
      node = Nokogiri::HTML.fragment(subject).css('thead tr th.mevent-links')
      expect(node.css('a').last[:href]).to eq('#top-of-page')
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_events: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
