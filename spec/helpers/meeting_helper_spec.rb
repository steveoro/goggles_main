# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingHelper, type: :helper do
  describe '#meeting_show_link' do
    let(:fixture_meeting) { GogglesDb::Meeting.includes(season: :federation_type).last(300).sample }
    let(:federation_code) { fixture_meeting.season.federation_type.code }
    let(:options) do
      {
        'meeting_id' => fixture_meeting.id,
        'federation_code' => federation_code,
        'meeting_date' => fixture_meeting.header_date,
        'meeting_description' => fixture_meeting.description
      }
    end

    context 'when rendering with valid option values,' do
      subject(:parsed_nodes) { Nokogiri::HTML.fragment(helper.meeting_show_link(options)) }

      before do
        expect(fixture_meeting).to be_a(GogglesDb::Meeting).and be_valid
        expect(federation_code).to be_a(String).and be_present
        expect(options).to be_an(Hash)
      end

      it 'renders a valid link' do
        expect(parsed_nodes.at('a')).to be_present
      end

      it 'shows the federation code' do
        expect(parsed_nodes.at('a').text).to include(federation_code)
      end

      it 'shows the meeting_date in string (ISO) format' do
        expect(parsed_nodes.at('a').text).to include(fixture_meeting.header_date.to_s)
      end

      it 'shows the meeting_description' do
        expect(parsed_nodes.at('a').text).to include(fixture_meeting.description)
      end

      it 'links to the meeting details page' do
        expect(parsed_nodes.at('a').attributes['href'].value).to include(meeting_show_path(id: fixture_meeting.id))
      end
    end

    context 'when rendering with a nil parameter,' do
      subject { helper.meeting_show_link(nil) }

      it 'is nil' do
        expect(subject).to be nil
      end
    end

    context 'when rendering with some missing parameters,' do
      subject do
        options.delete(%w[meeting_id federation_code meeting_date meeting_description].sample)
        helper.meeting_show_link(options)
      end

      before do
        expect(fixture_meeting).to be_a(GogglesDb::Meeting).and be_valid
        expect(federation_code).to be_a(String).and be_present
        expect(options).to be_an(Hash)
      end

      it 'is nil' do
        expect(subject).to be nil
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
