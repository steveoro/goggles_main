# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grid::RowStarButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:expired_meeting) { GogglesDb::Meeting.where('header_date < ?', Time.zone.today).last(50).sample }
  let(:unexpired_meeting) { FactoryBot.create(:meeting, header_date: Time.zone.today + 25.days) }
  let(:tagged_meeting) do
    meeting = FactoryBot.create(:meeting, header_date: Time.zone.today + 25.days)
    meeting.tags_by_user_list.add("u#{user.id}")
    meeting.save!
    meeting
  end

  let(:unexpired_calendar) { FactoryBot.create(:calendar, meeting: unexpired_meeting) }
  let(:tagged_calendar) { FactoryBot.create(:calendar, meeting: tagged_meeting) }
  let(:user) { GogglesDb::User.first(50).sample }

  before do
    expect(expired_meeting).to be_a(GogglesDb::Meeting).and be_valid
    expect(unexpired_meeting).to be_a(GogglesDb::Meeting).and be_valid
    expect(tagged_meeting).to be_a(GogglesDb::Meeting).and be_valid
    # Fixture meetings must be properly tagged & untagged:
    expect(unexpired_meeting.tags_by_user_list).not_to include("u#{user.id}")
    expect(tagged_meeting.tags_by_user_list).to include("u#{user.id}")
    # Same goes with Calendars:
    expect(unexpired_calendar.meeting_id).to eq(unexpired_meeting.id)
    expect(tagged_calendar.meeting_id).to eq(tagged_meeting.id)
  end

  context 'when using a Meeting row that is not expired' do
    context 'and not tagged, with a valid current user' do
      subject { render_inline(described_class.new(asset_row: unexpired_meeting, current_user: user)) }

      let(:expected_icon) { '.fa.fa-star-o' }
      let(:expected_color) { '.text-primary' }

      it 'renders the link button to toggle the star selection' do
        expect(subject.at("a#btn-row-star-#{unexpired_meeting.id}")).to be_present
        expect(subject.at("a#btn-row-star-#{unexpired_meeting.id}").attributes['href'].value)
          .to eq(taggings_by_user_path(meeting_id: unexpired_meeting.id))
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star-#{unexpired_meeting.id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star-#{unexpired_meeting.id} i#{expected_color}")).to be_present
      end
    end

    context 'and already tagged, with a valid current user' do
      subject { render_inline(described_class.new(asset_row: tagged_meeting, current_user: user)) }

      let(:expected_icon) { '.fa.fa-star' }
      let(:expected_color) { '.text-warning' }

      it 'renders the link button to toggle the star selection' do
        expect(subject.at("a#btn-row-star-#{tagged_meeting.id}")).to be_present
        expect(subject.at("a#btn-row-star-#{tagged_meeting.id}").attributes['href'].value)
          .to eq(taggings_by_user_path(meeting_id: tagged_meeting.id))
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star-#{tagged_meeting.id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star-#{tagged_meeting.id} i#{expected_color}")).to be_present
      end
    end

    context 'and an invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: unexpired_meeting, current_user: expired_meeting))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'and a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: unexpired_meeting, current_user: nil))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end

  context 'when using an \'expired\' Meeting row with other valid parameters' do
    subject { render_inline(described_class.new(asset_row: expired_meeting, current_user: user)) }

    it 'does not render any link' do
      expect(subject.at('a')).not_to be_present
    end

    it 'renders a disabled minus sign icon' do
      expect(subject.at('i.fa.fa-minus.text-secondary')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when using a Calendar associated to an unexpired meeting row' do
    context 'and not tagged, with other valid parameters' do
      subject { render_inline(described_class.new(asset_row: unexpired_calendar, current_user: user)) }

      let(:expected_icon) { '.fa.fa-star-o' }
      let(:expected_color) { '.text-primary' }

      it 'renders the link button to toggle the star selection' do
        expect(subject.at("a#btn-row-star-#{unexpired_calendar.meeting_id}")).to be_present
        expect(subject.at("a#btn-row-star-#{unexpired_calendar.meeting_id}").attributes['href'].value)
          .to eq(taggings_by_user_path(meeting_id: unexpired_calendar.meeting_id))
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star-#{unexpired_calendar.meeting_id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star-#{unexpired_calendar.meeting_id} i#{expected_color}")).to be_present
      end
    end

    context 'and already tagged, with a valid current user' do
      subject { render_inline(described_class.new(asset_row: tagged_calendar, current_user: user)) }

      let(:expected_icon) { '.fa.fa-star' }
      let(:expected_color) { '.text-warning' }

      it 'renders the link button to toggle the star selection' do
        expect(subject.at("a#btn-row-star-#{tagged_calendar.meeting_id}")).to be_present
        expect(subject.at("a#btn-row-star-#{tagged_calendar.meeting_id}").attributes['href'].value)
          .to eq(taggings_by_user_path(meeting_id: tagged_calendar.meeting_id))
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star-#{tagged_calendar.meeting_id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star-#{tagged_calendar.meeting_id} i#{expected_color}")).to be_present
      end
    end

    context 'and an invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: unexpired_calendar, current_user: expired_meeting))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'and a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: unexpired_calendar, current_user: nil))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an unsupported but present asset row plus other valid parameters values,' do
    subject do
      render_inline(described_class.new(asset_row: user, current_user: user))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a nil asset row plus other valid parameters values,' do
    subject do
      render_inline(described_class.new(asset_row: nil, current_user: user))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
