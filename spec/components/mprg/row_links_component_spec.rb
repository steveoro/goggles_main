# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mprg::RowLinksComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_event) do
      GogglesDb::MeetingEvent.joins(:meeting_programs)
                             .includes(:meeting_programs)
                             .first(100)
                             .sample
    end
    before(:each) do
      expect(fixture_event).to be_a(GogglesDb::MeetingEvent).and be_valid
      expect(fixture_event.meeting_programs.count).to be_positive
    end

    subject { render_inline(described_class.new(meeting_programs: fixture_event.meeting_programs)) }

    it 'renders a table header with 2 table rows' do
      expect(subject.css('thead tr')).to be_present
      expect(subject.css('thead tr').count).to eq(2)
    end
    it 'renders as many links to programs as the specified association' do
      expect(subject.css('thead tr th.mprg-links').css('a').count).to eq(fixture_event.meeting_programs.count)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_programs: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
