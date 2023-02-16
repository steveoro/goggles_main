# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grid::TeamStarButtonComponent, type: :component do
  let(:user) { GogglesDb::User.first(50).sample }
  let(:user_teams) { GogglesDb::Team.first(50).sample(2) }
  let(:user_team_ids) { user_teams.map(&:id) }
  let(:expired_meeting) { GogglesDb::Meeting.where('header_date < ?', Time.zone.today).last(50).sample }
  let(:unexpired_meeting) { FactoryBot.create(:meeting, header_date: Time.zone.today + 25.days) }
  let(:tagged_meeting) do
    meeting = FactoryBot.create(:meeting, header_date: Time.zone.today + 25.days)
    meeting.tags_by_team_list.add("t#{user_team_ids.sample}") # tag for a random team ID
    meeting.save!
    meeting
  end

  let(:unexpired_calendar) { FactoryBot.create(:calendar, meeting: unexpired_meeting) }
  let(:tagged_calendar) { FactoryBot.create(:calendar, meeting: tagged_meeting) }

  before do
    expect(user_teams).to be_an(Array).and be_present
    expect(expired_meeting).to be_a(GogglesDb::Meeting).and be_valid
    expect(unexpired_meeting).to be_a(GogglesDb::Meeting).and be_valid
    expect(tagged_meeting).to be_a(GogglesDb::Meeting).and be_valid
    # Fixture meetings must be properly tagged & untagged:
    expect(user_team_ids.none? { |team_id| unexpired_meeting.tags_by_team_list.include?("t#{team_id}") })
      .to be true
    expect(user_team_ids.any? { |team_id| tagged_meeting.tags_by_team_list.include?("t#{team_id}") })
      .to be true
    # Same goes with Calendars:
    expect(unexpired_calendar.meeting_id).to eq(unexpired_meeting.id)
    expect(tagged_calendar.meeting_id).to eq(tagged_meeting.id)
  end

  context 'when using a Meeting row that is not expired' do
    context 'and not tagged, with a valid current user' do
      subject do
        render_inline(
          described_class.new(asset_row: unexpired_meeting, current_user: user, user_teams: user_teams)
        )
      end

      let(:expected_icon) { '.fa.fa-calendar-o' }
      let(:expected_color) { '.text-secondary' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-team-star-#{unexpired_meeting.id}")).to be_present
        expect(subject.at("a#btn-team-star-#{unexpired_meeting.id}").attributes['href'].value).to eq('#team-star-modal')
      end

      it 'includes the JS script to setup the modal dialog' do
        expect(subject.at("a#btn-team-star-#{unexpired_meeting.id}").attributes['onclick'].value)
          .to include("$('#frm-team-star input#meeting_id').val(#{unexpired_meeting.id});")
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-team-star-#{unexpired_meeting.id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-team-star-#{unexpired_meeting.id} i#{expected_color}")).to be_present
      end
    end

    context 'and already tagged, with a valid current user' do
      subject do
        render_inline(
          described_class.new(asset_row: tagged_meeting, current_user: user, user_teams: user_teams)
        )
      end

      let(:expected_icon) { '.fa.fa-calendar' }
      let(:expected_color) { '.text-success' }

      it 'renders the link button to toggle the star selection' do
        expect(subject.at("a#btn-team-star-#{tagged_meeting.id}")).to be_present
        expect(subject.at("a#btn-team-star-#{tagged_meeting.id}").attributes['href'].value).to eq('#team-star-modal')
      end

      it 'includes the JS script to setup the modal dialog' do
        expect(subject.at("a#btn-team-star-#{tagged_meeting.id}").attributes['onclick'].value)
          .to include("$('#frm-team-star input#meeting_id').val(#{tagged_meeting.id});")
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-team-star-#{tagged_meeting.id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-team-star-#{tagged_meeting.id} i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(
          described_class.new(asset_row: unexpired_meeting, current_user: unexpired_calendar, user_teams: user_teams)
        ).to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: unexpired_meeting, current_user: nil, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end

  context 'when using an \'expired\' Meeting row with other valid parameters' do
    subject { render_inline(described_class.new(asset_row: expired_meeting, current_user: user, user_teams: user_teams)) }

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
      subject do
        render_inline(
          described_class.new(asset_row: unexpired_calendar, current_user: user, user_teams: user_teams)
        )
      end

      let(:expected_icon) { '.fa.fa-calendar-o' }
      let(:expected_color) { '.text-secondary' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-team-star-#{unexpired_calendar.meeting_id}")).to be_present
        expect(subject.at("a#btn-team-star-#{unexpired_calendar.meeting_id}").attributes['href'].value)
          .to eq('#team-star-modal')
      end

      it 'includes the JS script to setup the modal dialog' do
        expect(subject.at("a#btn-team-star-#{unexpired_calendar.meeting_id}").attributes['onclick'].value)
          .to include("$('#frm-team-star input#meeting_id').val(#{unexpired_calendar.meeting_id});")
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-team-star-#{unexpired_calendar.meeting_id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-team-star-#{unexpired_calendar.meeting_id} i#{expected_color}")).to be_present
      end
    end

    context 'and already tagged, with a valid current user' do
      subject do
        render_inline(
          described_class.new(asset_row: tagged_calendar, current_user: user, user_teams: user_teams)
        )
      end

      let(:expected_icon) { '.fa.fa-calendar' }
      let(:expected_color) { '.text-success' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-team-star-#{tagged_calendar.meeting_id}")).to be_present
        expect(subject.at("a#btn-team-star-#{tagged_calendar.meeting_id}").attributes['href'].value)
          .to eq('#team-star-modal')
      end

      it 'includes the JS script to setup the modal dialog' do
        expect(subject.at("a#btn-team-star-#{tagged_calendar.meeting_id}").attributes['onclick'].value)
          .to include("$('#frm-team-star input#meeting_id').val(#{tagged_calendar.meeting_id});")
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-team-star-#{tagged_calendar.meeting_id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-team-star-#{tagged_calendar.meeting_id} i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(
          described_class.new(asset_row: unexpired_calendar, current_user: unexpired_calendar, user_teams: user_teams)
        ).to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: unexpired_calendar, current_user: nil, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an unsupported but present asset row plus other valid parameters values,' do
    subject do
      render_inline(
        described_class.new(asset_row: user, current_user: user, user_teams: user_teams)
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a nil asset row plus other valid parameters values,' do
    subject do
      render_inline(described_class.new(asset_row: nil, current_user: user, user_teams: user_teams))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
