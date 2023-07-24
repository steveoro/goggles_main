# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingHelper do
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
        expect(subject).to be_nil
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
        expect(subject).to be_nil
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#cache_key_for_meeting' do
    let(:fixture_meeting_id) { (rand * 10_000).to_i }
    let(:fixture_action)  { %w[index for_swimmer for_team show team_results swimmer_results].sample }
    let(:team_id) { (rand * 10_000).to_i }
    let(:swimmer_id) { (rand * 10_000).to_i }
    let(:max_updated_at) { 15.minutes.ago }

    shared_examples_for('#cache_key_for_meeting default behaviour') do
      it 'is a non-empty String' do
        expect(result).to be_a(String).and be_present
      end

      it 'includes the action name' do
        expect(result).to include(fixture_action)
      end

      it 'includes the meeting id' do
        expect(result).to include(fixture_meeting_id.to_s)
      end

      it 'includes the max_updated_at as a number' do
        expect(result).to include(max_updated_at.to_i.to_s)
      end
    end

    context 'without team_id & swimmer_id,' do
      subject(:result) { helper.cache_key_for_meeting(action: fixture_action, meeting_id: fixture_meeting_id, max_updated_at:) }

      it_behaves_like('#cache_key_for_meeting default behaviour')
    end

    context 'with a team_id,' do
      subject(:result) { helper.cache_key_for_meeting(action: fixture_action, meeting_id: fixture_meeting_id, max_updated_at:, team_id:) }

      it_behaves_like('#cache_key_for_meeting default behaviour')

      it 'includes the team id' do
        expect(result).to include(team_id.to_s)
      end
    end

    context 'with a swimmer_id,' do
      subject(:result) do
        helper.cache_key_for_meeting(action: fixture_action, meeting_id: fixture_meeting_id, max_updated_at:, swimmer_id:)
      end

      it_behaves_like('#cache_key_for_meeting default behaviour')

      it 'includes the swimmer id' do
        expect(result).to include(swimmer_id.to_s)
      end
    end

    context 'with both a team_id & a swimmer_id,' do
      subject(:result) do
        helper.cache_key_for_meeting(action: fixture_action, meeting_id: fixture_meeting_id, max_updated_at:, team_id:,
                                     swimmer_id:)
      end

      it_behaves_like('#cache_key_for_meeting default behaviour')

      it 'includes the team id' do
        expect(result).to include(team_id.to_s)
      end

      it 'includes the swimmer id' do
        expect(result).to include(swimmer_id.to_s)
      end
    end
  end
end
