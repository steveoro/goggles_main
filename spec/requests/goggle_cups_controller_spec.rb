# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoggleCupsController do
  describe 'GET /goggle_cups' do
    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        get(goggle_cups_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user (not a manager or admin)' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
        get(goggle_cups_path)
      end

      it 'is a redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets an unauthorized flash message' do
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.unauthorized'))
      end
    end

    context 'with a signed-in admin' do
      let(:admin_user) do
        user = FactoryBot.create(:user)
        FactoryBot.create(:admin_grant, user: user)
        user
      end

      before do
        expect(admin_user).to be_a(GogglesDb::User).and be_valid
        sign_in(admin_user)
        get(goggle_cups_path)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with a signed-in team manager' do
      let(:manager) { FactoryBot.create(:user) }
      let(:team) { FactoryBot.create(:team) }
      let(:team_affiliation) { FactoryBot.create(:team_affiliation, team: team) }
      let(:managed_affiliation) { FactoryBot.create(:managed_affiliation, manager: manager, team_affiliation: team_affiliation) }

      before do
        managed_affiliation
        expect(manager).to be_a(GogglesDb::User).and be_valid
        expect(team).to be_a(GogglesDb::Team).and be_valid
        sign_in(manager)
      end

      it 'returns http success' do
        get(goggle_cups_path)
        expect(response).to have_http_status(:success)
      end

      it 'lists only cups belonging to managed teams for the selected year' do
        FactoryBot.create(:goggle_cup, team: team, season_year: 2025)
        other_team = FactoryBot.create(:team)
        FactoryBot.create(:goggle_cup, team: other_team, season_year: 2025)

        get(goggle_cups_path, params: { season_year: 2025, team_id: team.id })

        expect(response).to have_http_status(:success)
        expect(GogglesDb::GoggleCup.where(team_id: team.id, season_year: 2025).count).to eq(1)
      end

      it 'shows a message when no cups are available' do
        get(goggle_cups_path, params: { season_year: 2025, team_id: team.id })

        expect(response).to have_http_status(:success)
        expect(response.body).to include('alert alert-info')
      end
    end
  end

  describe 'GET /goggle_cups/:id/ranking' do
    let(:team) { FactoryBot.create(:team) }
    let(:swimmer) { FactoryBot.create(:swimmer, complete_name: 'TEST SWIMMER', year_of_birth: 1980) }
    let(:cup) do
      FactoryBot.create(:goggle_cup, team: team, description: 'Test Cup', season_year: 2025,
                                     swimmers_ids: swimmer.id.to_s)
    end
    let(:ranking_json) do
      {
        description: 'Test Cup', season_year: 2025, max_points: 1000, team_id: team.id,
        end_date: '2026-07-31', swimmer_ids: [swimmer.id], no_duplicated_events: false,
        data: {
          base_timings: {
            swimmer.id.to_s => [
              {
                'event_type_code' => '50SL', 'pool_type_code' => '25',
                'season_header_year' => 2022, 'total_hundredths' => 3100,
                'meeting_date' => '2022-02-01', 'meeting_name' => 'Base Meeting',
                'meeting_id' => 7, 'meeting_individual_result_id' => 777
              }
            ]
          },
          scores: {
            swimmer.id.to_s => [
              {
                'event_type_code' => '50SL', 'pool_type_code' => '25',
                'total_hundredths' => 3000, 'meeting_date' => '2025-01-15',
                'meeting_name' => 'Test Meeting', 'meeting_id' => 42,
                'meeting_individual_result_id' => 99, 'team_id' => team.id,
                'team_name' => 'TEST TEAM', 'old_total_hundredths' => 3200,
                'old_meeting_date' => '2024-01-10', 'old_meeting_name' => 'Old Meeting',
                'old_meeting_id' => 30, 'old_meeting_individual_result_id' => 88,
                'row_score' => 1066.67
              }
            ]
          }
        }
      }.to_json
    end

    before do
      expect(cup).to be_a(GogglesDb::GoggleCup).and be_valid
      expect(swimmer).to be_a(GogglesDb::Swimmer).and be_valid
      cup.update!(ranking_data: ranking_json)
    end

    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        get(goggle_cup_ranking_path(cup))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user (not a manager or admin)' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
        get(goggle_cup_ranking_path(cup))
      end

      it 'is a redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets an unauthorized flash message' do
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.unauthorized'))
      end
    end

    context 'with a signed-in admin' do
      let(:admin_user) do
        user = FactoryBot.create(:user)
        FactoryBot.create(:admin_grant, user: user)
        user
      end

      before do
        expect(admin_user).to be_a(GogglesDb::User).and be_valid
        sign_in(admin_user)
      end

      it 'returns http success as HTML fallback' do
        get(goggle_cup_ranking_path(cup))
        expect(response).to have_http_status(:success)
      end

      it 'renders the stored ranking' do
        get(goggle_cup_ranking_path(cup))
        expect(response.body).to include('TEST SWIMMER')
        expect(response.body).to include('1066.67')
      end

      it 'displays ranking export buttons and a base-timings link for the rendered ranking' do
        get(goggle_cup_ranking_path(cup))
        expect(response.body).to include(I18n.t('goggles_cup.export.ranking_csv'))
        expect(response.body).to include(I18n.t('goggles_cup.export.ranking_xls'))
        expect(response.body).to include(I18n.t('goggles_cup.export.ranking_pdf'))
        expect(response.body).to include(I18n.t('goggles_cup.base_timings.link'))
      end

      it 'returns a turbo stream for the ranking' do
        get(goggle_cup_ranking_path(cup, format: :turbo_stream))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response.body).to include('TEST SWIMMER')
      end
    end

    context 'with a signed-in team manager' do
      let(:manager) { FactoryBot.create(:user) }
      let(:team_affiliation) { FactoryBot.create(:team_affiliation, team: team) }
      let(:managed_affiliation) { FactoryBot.create(:managed_affiliation, manager: manager, team_affiliation: team_affiliation) }

      before do
        managed_affiliation
        expect(manager).to be_a(GogglesDb::User).and be_valid
        sign_in(manager)
      end

      it 'returns http success' do
        get(goggle_cup_ranking_path(cup))
        expect(response).to have_http_status(:success)
      end

      it 'renders the stored ranking for the managed team' do
        get(goggle_cup_ranking_path(cup))
        expect(response.body).to include('TEST SWIMMER')
      end

      it 'returns a turbo stream for the ranking' do
        get(goggle_cup_ranking_path(cup, format: :turbo_stream))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response.body).to include('TEST SWIMMER')
      end
    end

    context 'with a signed-in manager of a different team' do
      let(:manager) { FactoryBot.create(:user) }
      let(:other_team) { FactoryBot.create(:team) }
      let(:other_team_affiliation) { FactoryBot.create(:team_affiliation, team: other_team) }
      let(:managed_affiliation) { FactoryBot.create(:managed_affiliation, manager: manager, team_affiliation: other_team_affiliation) }

      before do
        managed_affiliation
        expect(other_team).to be_a(GogglesDb::Team).and be_valid
        expect(cup).to be_a(GogglesDb::GoggleCup).and be_valid
        sign_in(manager)
        get(goggle_cup_ranking_path(cup))
      end

      it 'is a redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets an unauthorized team flash message' do
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.unauthorized_team'))
      end

      it 'returns a turbo stream alert for unauthorized team access' do
        get(goggle_cup_ranking_path(cup, format: :turbo_stream))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response.body).to include('goggle-cup-ranking')
        expect(response.body).to include(I18n.t('goggle_cups.unauthorized_team'))
      end
    end

    it 'redirects with an alert when the cup has no ranking data' do
      cup.update!(ranking_data: nil)
      admin_user = FactoryBot.create(:user)
      FactoryBot.create(:admin_grant, user: admin_user)
      sign_in(admin_user)

      get(goggle_cup_ranking_path(cup))
      expect(response).to redirect_to(goggle_cups_path)
      expect(flash[:alert]).to eq(I18n.t('goggle_cups.info.no_ranking_data'))
    end

    it 'returns a turbo stream alert when the cup has no ranking data' do
      cup.update!(ranking_data: nil)
      admin_user = FactoryBot.create(:user)
      FactoryBot.create(:admin_grant, user: admin_user)
      sign_in(admin_user)

      get(goggle_cup_ranking_path(cup, format: :turbo_stream))
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include('goggle-cup-ranking')
      expect(response.body).to include(I18n.t('goggle_cups.info.no_ranking_data'))
    end

    it 'redirects with an alert when the cup is missing' do
      admin_user = FactoryBot.create(:user)
      FactoryBot.create(:admin_grant, user: admin_user)
      sign_in(admin_user)

      get(goggle_cup_ranking_path(id: 0))
      expect(response).to redirect_to(goggle_cups_path)
      expect(flash[:alert]).to eq(I18n.t('goggle_cups.cup_not_found'))
    end

    it 'returns a turbo stream alert when the cup is missing' do
      admin_user = FactoryBot.create(:user)
      FactoryBot.create(:admin_grant, user: admin_user)
      sign_in(admin_user)

      get(goggle_cup_ranking_path(id: 0, format: :turbo_stream))
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include('goggle-cup-ranking')
      expect(response.body).to include(I18n.t('goggle_cups.cup_not_found'))
    end

    context 'with ranking data and a logged-in admin' do
      let(:admin_user) do
        user = FactoryBot.create(:user)
        FactoryBot.create(:admin_grant, user: user)
        user
      end

      before do
        sign_in(admin_user)
      end

      it 'exports the ranking as CSV' do
        get(goggle_cup_ranking_path(cup, format: :csv))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to include('goggle-cup-')
        expect(response.body).to include('TEST SWIMMER')
        expect(response.body).to include('1066.67')
      end

      it 'exports the ranking as XLSX' do
        get(goggle_cup_ranking_path(cup, format: :xlsx))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq(Mime[:xlsx].to_s)
        expect(response.headers['Content-Disposition']).to include('goggle-cup-')
        expect(response.headers['Content-Disposition']).to include('.xlsx')
      end

      it 'exports the ranking as PDF' do
        get(goggle_cup_ranking_path(cup, format: :pdf))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('application/pdf')
        expect(response.headers['Content-Disposition']).to include('goggle-cup-')
        expect(response.headers['Content-Disposition']).to include('.pdf')
      end

      it 'exports the base timings as CSV sorted by swimmer name' do
        get(goggle_cup_ranking_path(cup, format: :csv, export_type: :base_timings))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to include('base-timings')
        expect(response.body).to include('TEST SWIMMER')
        expect(response.body).to include('50SL')
      end

      it 'exports the base timings as XLSX' do
        get(goggle_cup_ranking_path(cup, format: :xlsx, export_type: :base_timings))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq(Mime[:xlsx].to_s)
        expect(response.headers['Content-Disposition']).to include('base-timings')
        expect(response.headers['Content-Disposition']).to include('.xlsx')
      end

      it 'exports the base timings as PDF' do
        get(goggle_cup_ranking_path(cup, format: :pdf, export_type: :base_timings))
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq('application/pdf')
        expect(response.headers['Content-Disposition']).to include('base-timings')
        expect(response.headers['Content-Disposition']).to include('.pdf')
      end
    end
  end

  describe 'GET /goggle_cups/:id/base_timings' do
    let(:team) { FactoryBot.create(:team) }
    let(:swimmer) { FactoryBot.create(:swimmer, complete_name: 'TEST SWIMMER', year_of_birth: 1980) }
    let(:cup) do
      FactoryBot.create(:goggle_cup, team: team, description: 'Test Cup', season_year: 2025,
                                     swimmers_ids: swimmer.id.to_s)
    end
    let(:ranking_json) do
      {
        description: 'Test Cup', season_year: 2025, max_points: 1000, team_id: team.id,
        end_date: '2026-07-31', swimmer_ids: [swimmer.id], no_duplicated_events: false,
        data: {
          base_timings: {
            swimmer.id.to_s => [
              {
                'event_type_code' => '50SL', 'pool_type_code' => '25',
                'season_header_year' => 2022, 'total_hundredths' => 3100,
                'meeting_date' => '2022-02-01', 'meeting_name' => 'Base Meeting',
                'meeting_id' => 7, 'meeting_individual_result_id' => 777
              }
            ]
          },
          scores: {
            swimmer.id.to_s => [
              {
                'event_type_code' => '50SL', 'pool_type_code' => '25',
                'total_hundredths' => 3000, 'meeting_date' => '2025-01-15',
                'meeting_name' => 'Test Meeting', 'meeting_id' => 42,
                'meeting_individual_result_id' => 99, 'team_id' => team.id,
                'team_name' => 'TEST TEAM', 'old_total_hundredths' => 3200,
                'old_meeting_date' => '2024-01-10', 'old_meeting_name' => 'Old Meeting',
                'old_meeting_id' => 30, 'old_meeting_individual_result_id' => 88,
                'row_score' => 1066.67
              }
            ]
          }
        }
      }.to_json
    end

    before do
      expect(cup).to be_a(GogglesDb::GoggleCup).and be_valid
      expect(swimmer).to be_a(GogglesDb::Swimmer).and be_valid
      cup.update!(ranking_data: ranking_json)
    end

    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        get(goggle_cup_base_timings_path(cup))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user (not a manager or admin)' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
        get(goggle_cup_base_timings_path(cup))
      end

      it 'is a redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets an unauthorized flash message' do
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.unauthorized'))
      end
    end

    context 'with a signed-in admin' do
      let(:admin_user) do
        user = FactoryBot.create(:user)
        FactoryBot.create(:admin_grant, user: user)
        user
      end

      before do
        expect(admin_user).to be_a(GogglesDb::User).and be_valid
        sign_in(admin_user)
      end

      it 'returns http success' do
        get(goggle_cup_base_timings_path(cup))
        expect(response).to have_http_status(:success)
      end

      it 'renders the base timings page' do
        get(goggle_cup_base_timings_path(cup))
        expect(response.body).to include(I18n.t('goggles_cup.base_timings.title'))
        expect(response.body).to include('TEST SWIMMER')
      end

      it 'displays base-timings export buttons' do
        get(goggle_cup_base_timings_path(cup))
        expect(response.body).to include(I18n.t('goggles_cup.export.base_timings_csv'))
        expect(response.body).to include(I18n.t('goggles_cup.export.base_timings_xls'))
        expect(response.body).to include(I18n.t('goggles_cup.export.base_timings_pdf'))
      end

      it 'includes a link back to the ranking' do
        get(goggle_cup_base_timings_path(cup))
        expect(response.body).to include(I18n.t('goggles_cup.base_timings.back_to_ranking'))
      end
    end

    context 'with a signed-in team manager' do
      let(:manager) { FactoryBot.create(:user) }
      let(:team_affiliation) { FactoryBot.create(:team_affiliation, team: team) }
      let(:managed_affiliation) { FactoryBot.create(:managed_affiliation, manager: manager, team_affiliation: team_affiliation) }

      before do
        managed_affiliation
        expect(manager).to be_a(GogglesDb::User).and be_valid
        sign_in(manager)
      end

      it 'returns http success' do
        get(goggle_cup_base_timings_path(cup))
        expect(response).to have_http_status(:success)
      end

      it 'renders the base timings for the managed team' do
        get(goggle_cup_base_timings_path(cup))
        expect(response.body).to include('TEST SWIMMER')
      end
    end

    context 'with a signed-in manager of a different team' do
      let(:manager) { FactoryBot.create(:user) }
      let(:other_team) { FactoryBot.create(:team) }
      let(:other_team_affiliation) { FactoryBot.create(:team_affiliation, team: other_team) }
      let(:managed_affiliation) { FactoryBot.create(:managed_affiliation, manager: manager, team_affiliation: other_team_affiliation) }

      before do
        managed_affiliation
        expect(other_team).to be_a(GogglesDb::Team).and be_valid
        expect(cup).to be_a(GogglesDb::GoggleCup).and be_valid
        sign_in(manager)
        get(goggle_cup_base_timings_path(cup))
      end

      it 'is a redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets an unauthorized team flash message' do
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.unauthorized_team'))
      end
    end

    it 'redirects with an alert when the cup has no ranking data' do
      cup.update!(ranking_data: nil)
      admin_user = FactoryBot.create(:user)
      FactoryBot.create(:admin_grant, user: admin_user)
      sign_in(admin_user)

      get(goggle_cup_base_timings_path(cup))
      expect(response).to redirect_to(goggle_cups_path)
      expect(flash[:alert]).to eq(I18n.t('goggle_cups.info.no_ranking_data'))
    end

    it 'redirects with an alert when the cup is missing' do
      admin_user = FactoryBot.create(:user)
      FactoryBot.create(:admin_grant, user: admin_user)
      sign_in(admin_user)

      get(goggle_cup_base_timings_path(id: 0))
      expect(response).to redirect_to(goggle_cups_path)
      expect(flash[:alert]).to eq(I18n.t('goggle_cups.cup_not_found'))
    end
  end
end
