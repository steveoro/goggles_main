# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_decorator_examples'

RSpec.describe MeetingDecorator, type: :decorator do
  subject { described_class.decorate(model_obj) }

  let(:model_obj) { GogglesDb::Meeting.limit(50).sample }

  it_behaves_like('a paginated model decorated with', described_class)

  describe '#link_to_full_name' do
    let(:result) { subject.link_to_full_name }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the decorated #display_label' do
      expect(result).to include(ERB::Util.html_escape(model_obj.decorate.display_label))
    end

    it 'includes the path to the detail page' do
      expect(result).to include(h.meeting_show_path(id: model_obj.id))
    end
  end

  describe '#hash_of_session_dates_and_event_type_codes' do
    context 'for a meeting with more than 1 session,' do
      let(:meeting_multiple_sessions) do
        # Count meeting_sessions for each meeting, and pick a random meeting with more than 1 session:
        m = GogglesDb::Meeting.joins(:meeting_sessions).group('meetings.id').having('count(meeting_sessions.id) > 1').sample
        described_class.decorate(m)
      end

      let(:result) { meeting_multiple_sessions.hash_of_session_dates_and_event_type_codes }

      it 'is a non-empty Hash' do
        expect(result).to be_a(Hash).and be_present
      end

      it 'includes a key for each session date' do
        session_keys = meeting_multiple_sessions.meeting_sessions.map { |ms| ms.scheduled_date.to_s }.uniq
        expect(result.keys).to match_array(session_keys)
      end

      it 'includes a value for each list labels of event_types in each session' do
        list_of_event_lists = meeting_multiple_sessions.meeting_sessions.map { |ms| ms.meeting_events.map { |me| me.event_type.label } }
        expect(result.values.flatten).to match_array(list_of_event_lists.flatten)
      end
    end

    context 'for a meeting with no sessions,' do
      let(:meeting_no_sessions) do
        m = GogglesDb::Meeting.left_outer_joins(:meeting_sessions).group('meetings.id').having('count(meeting_sessions.id) = 0').sample
        described_class.decorate(m)
      end

      let(:result) { meeting_no_sessions.hash_of_session_dates_and_event_type_codes }

      it 'is an empty Hash' do
        expect(result).to be_a(Hash).and be_empty
      end
    end
  end
end
