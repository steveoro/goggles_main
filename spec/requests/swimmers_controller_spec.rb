# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe SwimmersController do
  let(:fixture_row_id) { GogglesDb::Swimmer.first(100).pluck(:id).sample }

  describe 'GET /show/:id' do
    context 'with a valid row id' do
      it 'returns http success' do
        get(swimmer_show_path(fixture_row_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(swimmer_show_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /history_recap/:id' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(swimmer_history_recap_path(fixture_row_id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      context 'with a valid row id' do
        it 'is successful' do
          get(swimmer_history_recap_path(fixture_row_id))
          expect(response).to have_http_status(:success)
        end
      end

      context 'with an invalid row id' do
        before { get(swimmer_history_recap_path(-1)) }

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /goggles_cup_base_timings/:id' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(swimmer_goggles_cup_base_timings_path(fixture_row_id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      context 'with a valid row id' do
        it 'is successful' do
          get(swimmer_goggles_cup_base_timings_path(fixture_row_id))
          expect(response).to have_http_status(:success)
        end

        it 'defaults to the current base championship year' do
          GogglesDb::GogglesCup3yBaseTimings.connection.execute('SET @base_year = NULL')
          default_year = GogglesDb::GogglesCup3yBaseTimings.connection.select_value('SELECT goggles_db_base_year()')
          get(swimmer_goggles_cup_base_timings_path(fixture_row_id))
          expect(response.body).to include(I18n.t('swimmers.radiography.base_year_header', base_year: default_year))
        end
      end

      context 'with a valid base_year parameter' do
        it 'is successful' do
          get(swimmer_goggles_cup_base_timings_path(fixture_row_id, base_year: 2022))
          expect(response).to have_http_status(:success)
        end

        it 'uses the requested base championship year' do
          get(swimmer_goggles_cup_base_timings_path(fixture_row_id, base_year: 2022))
          expect(response.body).to include(I18n.t('swimmers.radiography.base_year_header', base_year: 2022))
        end

        it 'does not leak the base_year to the next default fallback request' do
          get(swimmer_goggles_cup_base_timings_path(fixture_row_id, base_year: 2022))
          expect(response.body).to include(I18n.t('swimmers.radiography.base_year_header', base_year: 2022))

          GogglesDb::GogglesCup3yBaseTimings.connection.execute('SET @base_year = NULL')
          default_year = GogglesDb::GogglesCup3yBaseTimings.connection.select_value('SELECT goggles_db_base_year()')

          get(swimmer_goggles_cup_base_timings_path(fixture_row_id, base_year: 'invalid'))
          expect(response.body).to include(I18n.t('swimmers.radiography.base_year_header', base_year: default_year))
        end
      end

      context 'with an invalid row id' do
        before { get(swimmer_goggles_cup_base_timings_path(-1)) }

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET XHR /event_type_stats' do
    let(:event_type_id) { GogglesDb::EventType.all_individuals.sample.id }

    context 'making a plain HTML request,' do
      before do
        get(
          swimmer_event_type_stats_path(id: fixture_row_id, event_type_id:, event_total: (1 + (rand * 10)).to_i)
        )
      end

      it 'redirects to swimmer history recap without warning' do
        expect(response).to redirect_to(swimmer_history_recap_path(fixture_row_id))
        expect(flash[:warning]).to be_nil
      end
    end

    context 'making a Turbo Stream request with valid parameters,' do
      before do
        get(
          swimmer_event_type_stats_path(id: fixture_row_id, event_type_id:, event_total: (1 + (rand * 10)).to_i),
          headers: { 'ACCEPT' => Mime[:turbo_stream].to_s }
        )
      end

      it 'is successful' do
        expect(response).to be_successful
      end
    end

    context 'making a Turbo Stream request with missing or invalid parameters,' do
      before do
        get(
          swimmer_event_type_stats_path(id: fixture_row_id, event_type_id:, event_total: 0),
          headers: { 'ACCEPT' => Mime[:turbo_stream].to_s }
        )
      end

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /history/:id' do
    let(:event_type_id) { GogglesDb::EventType.all_individuals.pluck(:id).sample }

    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(swimmer_history_path(id: fixture_row_id, event_type_id:))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      context 'with valid parameters' do
        it 'is successful' do
          get(swimmer_history_path(id: fixture_row_id, event_type_id:))
          expect(response).to have_http_status(:success)
        end
      end

      context 'with an invalid swimmer id' do
        before { get(swimmer_history_path(id: 0, event_type_id:)) }

        it_behaves_like('invalid row id GET request')
      end

      context 'with an invalid event_type_id' do
        before { get(swimmer_history_path(id: fixture_row_id, event_type_id: 0)) }

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /swimmers/goggles_cup_ranking/:id' do
    let(:swimmer) { FactoryBot.create(:swimmer, complete_name: 'CUP TEST SWIMMER') }
    let(:current_year) { GogglesDb::Season.current_championship_year(GogglesDb::SeasonType.mas_fin) }
    let(:user) { FactoryBot.create(:user, swimmer_id: swimmer.id) }

    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(swimmer_goggles_cup_ranking_path(swimmer.id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before { sign_in(FactoryBot.create(:user)) }

      it 'redirects back with a "not enrolled" alert' do
        get(swimmer_goggles_cup_ranking_path(swimmer.id))
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.errors.not_enrolled'))
      end
    end

    context 'with a logged-in user whose swimmer has no published cup,' do
      before do
        FactoryBot.create(:goggle_cup, season_year: current_year,
                                       swimmers_ids: swimmer.id.to_s, published: false)
        sign_in(user)
      end

      it 'redirects back with a "not enrolled" alert' do
        get(swimmer_goggles_cup_ranking_path(swimmer.id))
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.errors.not_enrolled'))
      end
    end

    context 'with a logged-in user whose swimmer is enlisted in a published cup,' do
      before do
        FactoryBot.create(:goggle_cup, season_year: current_year,
                                       swimmers_ids: swimmer.id.to_s, published: true)
        sign_in(user)
      end

      it 'renders the precomputed ranking page' do
        get(swimmer_goggles_cup_ranking_path(swimmer.id))
        expect(response).to have_http_status(:success)
        expect(response.body).to include('CUP TEST SWIMMER')
      end

      it 'renders no export controls' do
        get(swimmer_goggles_cup_ranking_path(swimmer.id))
        expect(response.body).not_to include('export_type')
      end

      it 'links the base timings for the cup season year' do
        get(swimmer_goggles_cup_ranking_path(swimmer.id))
        expect(response.body).to include("base_year=#{current_year}")
      end
    end

    context 'when the requested swimmer id is not the current user\'s swimmer,' do
      let(:other_swimmer) { FactoryBot.create(:swimmer) }

      before do
        FactoryBot.create(:goggle_cup, season_year: current_year,
                                       swimmers_ids: swimmer.id.to_s, published: true)
        sign_in(user)
      end

      it 'redirects back with a "not enrolled" alert' do
        get(swimmer_goggles_cup_ranking_path(other_swimmer.id))
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('goggle_cups.errors.not_enrolled'))
      end

      it 'skips the enlisted-cup lookup and keeps the remembered swimmer cookie' do
        allow(GogglesDb::GoggleCup).to receive(:latest_published_involving).and_call_original
        cookies[:swimmer_id] = swimmer.id
        get(swimmer_goggles_cup_ranking_path(other_swimmer.id))
        expect(GogglesDb::GoggleCup).not_to have_received(:latest_published_involving)
        expect(cookies[:swimmer_id]).to eq(swimmer.id.to_s)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
