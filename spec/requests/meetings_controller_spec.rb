# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe MeetingsController do
  describe 'GET /index' do
    context 'with an un-logged user' do
      it 'is a redirect to the login path' do
        get(meetings_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is a redirect to the root path' do
        get(meetings_path)
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash warning about the missing swimmer association' do
        get(meetings_path)
        expect(flash[:warning]).to eq(I18n.t('home.my.errors.no_associated_swimmer'))
      end
    end

    context 'with a logged-in user associated to a swimmer,' do
      before do
        user = GogglesDb::User.includes(swimmer: [:gender_type])
                              .joins(swimmer: [:gender_type])
                              .first(50)
                              .sample
        expect(user).to be_a(GogglesDb::User).and be_valid
        expect(user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        sign_in(user)
      end

      it 'is successful' do
        get(meetings_path)
        expect(response).to be_successful
      end

      context 'when filtering data by :meeting_date,' do
        it 'is successful' do
          get(meetings_path(meetings_grid: { meeting_date: '2019-12-15' }))
          expect(response).to be_successful
        end
      end

      context 'when filtering data by :meeting_name,' do
        it 'is successful' do
          get(meetings_path(meetings_grid: { meeting_name: 'Riccione' }))
          expect(response).to be_successful
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /show/:id' do
    context 'with a valid row id' do
      let(:meeting_id) { GogglesDb::Meeting.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(meeting_show_path(meeting_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(meeting_show_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET XHR /show_event_section' do
    # (Older meeting events are more likely to have results already defined)
    let(:meeting_event_id) { GogglesDb::MeetingEvent.first(300).pluck(:id).sample }

    context 'making a plain HTML request,' do
      before { get(meeting_show_event_section_path(id: meeting_event_id)) }

      it_behaves_like('invalid row id GET request')
    end

    context 'making an XHR request with valid parameters,' do
      before do
        get(meeting_show_event_section_path(id: meeting_event_id), xhr: true)
      end

      it 'is successful' do
        expect(response).to be_successful
      end
    end

    context 'making an XHR request with missing or invalid parameters,' do
      before { get(meeting_show_event_section_path(id: 0), xhr: true) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /for_swimmer/:id' do
    context 'with a valid row id' do
      let(:swimmer_id) { GogglesDb::Swimmer.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(meetings_for_swimmer_path(swimmer_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(meetings_for_swimmer_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /for_team/:id' do
    context 'with a valid row id' do
      let(:team_id) { GogglesDb::Team.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(meetings_for_swimmer_path(team_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(meetings_for_team_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /team_results/:id' do
    # Make sure we select a meeting with actual results, at least:
    let(:meeting_id) do
      GogglesDb::Meeting.includes(:meeting_individual_results)
                        .joins(:meeting_individual_results)
                        .first(250).pluck(:id)
                        .sample
    end

    # Logged or unlogged, the result is the same:
    context 'with an invalid row id' do
      before { get(meeting_team_results_path(meeting_id)) }

      it_behaves_like('invalid row id GET request')
    end

    # From all the rest of the describe, 'with a valid row id' is implied for brevity:
    context 'with an un-logged user' do
      context 'when using a valid row id,' do
        before { get(meeting_team_results_path(meeting_id)) }

        it_behaves_like('invalid row id GET request')
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
        get(meeting_team_results_path(meeting_id))
      end

      it_behaves_like('invalid row id GET request')
    end

    context 'with a logged-in user linked to a swimmer & team but not present in the results,' do
      let(:fixture_season) { GogglesDb::Meeting.find(meeting_id).season }
      let(:fixture_badge)  { FactoryBot.create(:badge, season: fixture_season) }

      before do
        # Creating the badge from scratch will make sure that we won't have any meeting results
        # for this team & swimmer combo:
        expect(fixture_season).to be_a(GogglesDb::Season).and be_valid
        expect(fixture_badge).to be_a(GogglesDb::Badge).and be_valid
        user = FactoryBot.create(:user)
        user.associate_to_swimmer!(fixture_badge.swimmer)
        sign_in(user)
        get(meeting_team_results_path(meeting_id))
      end

      it 'redirects to the meetings/show page' do
        expect(response).to redirect_to(meeting_show_path(meeting_id))
      end

      it 'sets a flash warning for the invalid request' do
        expect(flash[:warning]).to eq(I18n.t('meetings.no_results_to_show_for_team', team: fixture_badge.team.editable_name))
      end
    end

    context 'with a logged-in user linked to a swimmer & team AND present in the chosen results,' do
      let(:fixture_mir) do
        GogglesDb::MeetingIndividualResult.includes(:meeting, :swimmer, :team)
                                          .joins(:meeting, :swimmer, :team)
                                          .where('meetings.id': meeting_id)
                                          .sample
      end
      let(:fixture_swimmer) { fixture_mir.swimmer }
      let(:fixture_team)    { fixture_mir.team }

      before do
        expect(meeting_id).to be_positive
        expect(fixture_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
        expect(fixture_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        expect(fixture_team).to be_a(GogglesDb::Team).and be_valid

        user = FactoryBot.create(:user)
        user.associate_to_swimmer!(fixture_swimmer)
        sign_in(user)
        get(meeting_team_results_path(meeting_id), params: { team_id: fixture_mir.team_id })
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /swimmer_results/:id' do
    # Make sure we select a meeting with actual results, at least:
    let(:meeting_id) do
      GogglesDb::Meeting.includes(:meeting_individual_results)
                        .joins(:meeting_individual_results)
                        .first(200).pluck(:id)
                        .sample
    end

    # Logged or unlogged, the result is the same:
    context 'with an invalid row id' do
      before { get(meeting_swimmer_results_path(meeting_id)) }

      it_behaves_like('invalid row id GET request')
    end

    # From all the rest of the describe, 'with a valid row id' is implied for brevity:
    context 'with an un-logged user' do
      context 'when using a valid row id,' do
        before { get(meeting_swimmer_results_path(meeting_id)) }

        it_behaves_like('invalid row id GET request')
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
        get(meeting_swimmer_results_path(meeting_id))
      end

      it_behaves_like('invalid row id GET request')
    end

    context 'with a logged-in user linked to a swimmer & team but not present in the results,' do
      let(:fixture_season) { GogglesDb::Meeting.find(meeting_id).season }
      let(:fixture_badge)  { FactoryBot.create(:badge, season: fixture_season) }

      before do
        # Creating the badge from scratch will make sure that we won't have any meeting results
        # for this team & swimmer combo:
        expect(fixture_season).to be_a(GogglesDb::Season).and be_valid
        expect(fixture_badge).to be_a(GogglesDb::Badge).and be_valid
        user = FactoryBot.create(:user)
        user.associate_to_swimmer!(fixture_badge.swimmer)
        sign_in(user)
        get(meeting_swimmer_results_path(meeting_id))
      end

      it 'redirects to the meetings/show page' do
        expect(response).to redirect_to(meeting_show_path(meeting_id))
      end

      it 'sets a flash warning for the invalid request' do
        expect(flash[:warning]).to eq(I18n.t('meetings.no_results_to_show_for_swimmer', swimmer: fixture_badge.swimmer.complete_name))
      end
    end

    context 'with a logged-in user linked to a swimmer & team AND present in the chosen results,' do
      let(:fixture_mir) do
        GogglesDb::MeetingIndividualResult.includes(:meeting, :swimmer, :team)
                                          .joins(:meeting, :swimmer, :team)
                                          .where('meetings.id': meeting_id)
                                          .last(200)
                                          .sample
      end
      let(:fixture_swimmer) { fixture_mir.swimmer }
      let(:fixture_team)    { fixture_mir.team }

      before do
        expect(meeting_id).to be_positive
        expect(fixture_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
        expect(fixture_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        expect(fixture_team).to be_a(GogglesDb::Team).and be_valid

        user = FactoryBot.create(:user)
        user.associate_to_swimmer!(fixture_swimmer)
        sign_in(user)
        get(meeting_swimmer_results_path(meeting_id), params: { swimmer_id: fixture_mir.swimmer_id })
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
