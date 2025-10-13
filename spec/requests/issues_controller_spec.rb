# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssuesController do
  %i[
    issues_faq_index_path issues_my_reports_path issues_new_type0_path
  ].each do |path_to_be_tested|
    describe "GET #{path_to_be_tested}" do
      context 'with an unlogged user' do
        it 'is a redirect to the login path' do
          get(send(path_to_be_tested))
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'with a logged-in user' do
        before do
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          get(send(path_to_be_tested))
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  let(:parent_result) do
    [
      GogglesDb::MeetingIndividualResult.last(500).sample,
      GogglesDb::UserResult.last(150).sample
    ].sample
  end
  let(:parent_meeting) { parent_result.parent_meeting }
  let(:fixture_team) { GogglesDb::Team.last(200).sample }
  let(:fixture_swimmer) { GogglesDb::Swimmer.last(100).sample }
  let(:fixture_season_ids) { { '1' => 182, '2' => 192, '3' => 202 } }

  before do
    expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid
    expect(parent_meeting).to be_an(GogglesDb::AbstractMeeting).and be_valid
    expect(fixture_team).to be_an(GogglesDb::Team).and be_valid
    expect(fixture_swimmer).to be_an(GogglesDb::Swimmer).and be_valid
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'DELETE /issues/destroy/:id' do
    let(:deletable_row) { FactoryBot.create(:issue) }

    before { expect(deletable_row).to be_a(GogglesDb::Issue).and be_valid }

    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        delete(issues_destroy_path(id: deletable_row.id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      context 'but with an invalid row ID' do
        before do
          expect(GogglesDb::Issue.exists?(id: 0)).to be false
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          delete(issues_destroy_path(id: 0))
        end

        it 'is a redirect to the \'my reports\' page' do
          expect(response).to redirect_to(issues_my_reports_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          delete(issues_destroy_path(id: deletable_row.id))
        end

        it 'redirects to the \'my reports\' page' do
          expect(response).to redirect_to(issues_my_reports_path)
        end

        it 'sets a successful flash notice' do
          expect(flash[:notice]).to eq(I18n.t('issues.grid.delete_done'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /issues/new_type1b/' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(
          issues_new_type1b_path,
          params: {
            parent_meeting_id: parent_meeting.id,
            parent_meeting_class: parent_meeting.class.name.split('::').last
          }
        )
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      context 'but missing some required parameters' do
        before do
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          get(issues_new_type1b_path)
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          get(
            issues_new_type1b_path,
            params: {
              parent_meeting_id: parent_meeting.id,
              parent_meeting_class: parent_meeting.class.name.split('::').last
            }
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  %i[
    issues_new_type1b1_path issues_new_type2b1_path
  ].each do |path_to_be_tested|
    describe "GET #{path_to_be_tested}" do
      context 'with an unlogged user' do
        it 'is a redirect to the login path' do
          get(send(path_to_be_tested))
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context 'with a logged-in user' do
      context 'but missing some required parameters' do
        before do
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          get(send(path_to_be_tested))
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          user = GogglesDb::User.first(50).sample
          sign_in(user)
          get(
            send(path_to_be_tested),
            params: {
              result_id: parent_result.id,
              result_class: parent_result.class.name.split('::').last
            }
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # == ASSERT/REQUIRES:
  # - path_to_be_tested: the path that will be called by the POST method
  # - params: the params Hash for the call
  #
  shared_examples_for('issues POST request w/ varying parameters and context') do |warn_msg_key|
    context 'with an unlogged user' do
      before do
        post(
          path_to_be_tested,
          params:,
          headers: { 'HTTP_REFERER' => issues_faq_index_path } # (Not needed & not tested: kept just for reference)
        )
      end

      it 'is a redirect to the login path' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      context 'but missing some required parameters' do
        before do
          user = FactoryBot.create(:user)
          sign_in(user)
          wrong_params = params.dup
          wrong_params.delete(wrong_params.keys.sample)
          post(path_to_be_tested, params: wrong_params)
        end

        it 'is a redirect to the issues index' do
          expect(response).to redirect_to(issues_my_reports_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:info]).to be_blank # (as counterproof)
          correct_msg_key = warn_msg_key || 'issues.type1b.msg.missing_parameters'
          expect(flash[:warning]).to eq(I18n.t(correct_msg_key))
        end
      end

      context 'and valid parameters' do
        before do
          # Create a fresh user for each test to avoid conflicts with existing team managers
          # or hitting the SPAM_LIMIT due to random user selection
          user = FactoryBot.create(:user)
          sign_in(user)
          post(
            path_to_be_tested,
            params:,
            headers: { 'HTTP_REFERER' => issues_faq_index_path } # (Not needed & not tested: kept just for reference)
          )
        end

        it 'is a redirect to the issues index' do
          expect(response).to redirect_to(issues_my_reports_path)
        end

        it 'sets the ok flash info message' do
          expect(flash[:info]).to eq(I18n.t('issues.sent_ok'))
          expect(flash[:warning]).to be_blank # (as counterproof)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type0' do
    let(:path_to_be_tested) { issues_create_type0_path }
    let(:params) { { team_id: fixture_team.id, season: fixture_season_ids } }

    it_behaves_like('issues POST request w/ varying parameters and context')
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type1a' do
    let(:path_to_be_tested) { issues_create_type1a_path }

    context 'when specifying an existing meeting_id' do
      let(:params) { { meeting_id: parent_meeting.id, results_url: FFaker::Internet.http_url } }

      it_behaves_like('issues POST request w/ varying parameters and context')
    end

    context 'when specifying just a meeting label' do
      let(:params) { { meeting_label: "Won't care which Meeting description I use", results_url: FFaker::Internet.http_url } }

      it_behaves_like('issues POST request w/ varying parameters and context')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type1b' do
    let(:path_to_be_tested) { issues_create_type1b_path }
    let(:params) do
      {
        event_type_id: parent_meeting.event_types.pluck(:id).sample,
        swimmer_id: fixture_swimmer.id,
        parent_meeting_id: parent_meeting.id,
        parent_meeting_class: parent_meeting.class.name.split('::').last,
        minutes: 0, seconds: (rand * 50).to_i, hundredths: (rand * 80).to_i
      }
    end

    it_behaves_like('issues POST request w/ varying parameters and context')
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type1b1' do
    let(:path_to_be_tested) { issues_create_type1b1_path }
    let(:params) do
      {
        result_id: parent_result.id,
        result_class: parent_result.class.name.split('::').last,
        minutes: 0, seconds: (rand * 50).to_i, hundredths: (rand * 80).to_i
      }
    end

    it_behaves_like('issues POST request w/ varying parameters and context', 'search_view.errors.invalid_request')
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type2b1' do
    let(:path_to_be_tested) { issues_create_type2b1_path }
    let(:params) do
      {
        result_id: parent_result.id,
        result_class: parent_result.class.name.split('::').last,
        wrong_swimmer: '1'
      }
    end

    it_behaves_like('issues POST request w/ varying parameters and context', 'search_view.errors.invalid_request')
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type3b' do
    let(:path_to_be_tested) { issues_create_type3b_path }
    let(:params) do
      {
        swimmer_id: fixture_swimmer.id
        # [20230321] Made all swimmer-defining remaining parameters optional because now the user is supposed
        # to request issue 3c for a free-form swimmer association
      }
    end

    it_behaves_like('issues POST request w/ varying parameters and context', 'search_view.errors.invalid_request')
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type3c' do
    let(:path_to_be_tested) { issues_create_type3c_path }
    let(:params) do
      {
        type3c_first_name: fixture_swimmer.first_name,
        type3c_last_name: fixture_swimmer.last_name,
        type3c_gender_type_id: fixture_swimmer.gender_type_id,
        type3c_year_of_birth: fixture_swimmer.year_of_birth
      }
    end

    it_behaves_like('issues POST request w/ varying parameters and context', 'search_view.errors.invalid_request')
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /issues/create_type4' do
    let(:path_to_be_tested) { issues_create_type4_path }
    let(:params) do
      {
        expected: FFaker::CheesyLingo.sentence,
        outcome: FFaker::CheesyLingo.sentence,
        reproduce: FFaker::CheesyLingo.sentence
      }
    end

    it_behaves_like('issues POST request w/ varying parameters and context', 'search_view.errors.invalid_request')
  end
  #-- -------------------------------------------------------------------------
  #++
end
