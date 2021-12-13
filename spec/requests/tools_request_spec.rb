# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools', type: :request do
  describe 'GET /fin_score' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(tools_fin_score_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      it 'is successful' do
        get(tools_fin_score_path)
        expect(response).to be_successful
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET XHR /compute_fin_score' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(tools_compute_fin_score_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      let(:current_user) { GogglesDb::User.first(50).sample }

      before { sign_in(current_user) }

      context 'making a plain HTML request,' do
        before { get(tools_compute_fin_score_path) }

        it 'is a redirect to root_path' do
          expect(response).to redirect_to(root_path)
        end

        it 'set the flash error message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'making an XHR request' do
        let(:jwt_token) do
          GogglesDb::JWTManager.encode(
            { user_id: current_user.id },
            Rails.application.credentials.api_static_key
          )
        end
        let(:fixture_headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
        let(:last_fin_season) do
          GogglesDb::StandardTiming.includes(:season_type)
                                   .joins(:season_type)
                                   .where('seasons.season_type_id': GogglesDb::SeasonType::MAS_FIN_ID)
                                   .last.season
        end
        let(:fixture_pool_type) { GogglesDb::PoolType.all_eventable.sample }
        let(:fixture_event_type) do
          GogglesDb::EventsByPoolType.eventable.individuals
                                     .for_pool_type(fixture_pool_type)
                                     .event_length_between(50, 1500)
                                     .sample
                                     .event_type
        end
        let(:fixture_gender_type) { GogglesDb::GenderType.first(2).sample }
        let(:fixture_category_type) { last_fin_season.category_types.sample }
        let(:fixture_mir) do
          # Used just as reference timing:
          GogglesDb::MeetingIndividualResult.joins(:event_type, :pool_type)
                                            .where('event_types.id = ? AND pool_types.id = ?',
                                                   fixture_event_type.id, fixture_pool_type.id)
                                            .first(200).sample
        end
        let(:api_score_request_params) do
          {
            season_id: last_fin_season.id,
            event_type_id: fixture_event_type.id, pool_type_id: fixture_pool_type.id,
            minutes: fixture_mir.minutes, seconds: fixture_mir.seconds, hundredths: fixture_mir.hundredths,
            gender_type_id: fixture_gender_type.id, category_type_id: fixture_category_type.id
          }
        end
        let(:api_timing_request_params) do
          {
            season_id: last_fin_season.id,
            event_type_id: fixture_event_type.id, pool_type_id: fixture_pool_type.id,
            score: fixture_mir.standard_points.to_i,
            gender_type_id: fixture_gender_type.id, category_type_id: fixture_category_type.id
          }
        end

        before do
          expect(jwt_token).to be_a(String).and be_present
          expect(fixture_headers).to be_a(Hash).and be_present
          expect(fixture_pool_type).to be_a(GogglesDb::PoolType).and be_valid
          expect(fixture_event_type).to be_a(GogglesDb::EventType).and be_valid
          expect(fixture_gender_type).to be_a(GogglesDb::GenderType).and be_valid
          expect(fixture_category_type).to be_a(GogglesDb::CategoryType).and be_valid
          expect(fixture_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
        end

        context 'with valid parameters for computing the target score,' do
          before do
            stub_request(:get, %r{/api/v3/tools/compute_score}i)
              .with(query: hash_excluding(score: anything))
              .to_return(
                status: 200,
                body: {
                  timing: {
                    minutes: fixture_mir.minutes,
                    seconds: fixture_mir.seconds,
                    hundredths: fixture_mir.hundredths
                  },
                  score: 900 # (whatever: not checked)
                }.to_json
              )
            get(tools_compute_fin_score_path, xhr: true, params: api_score_request_params)
          end

          it 'is successful' do
            expect(response).to be_successful
          end
        end

        context 'with valid parameters for computing the target timing,' do
          before do
            stub_request(:get, %r{/api/v3/tools/compute_score}i)
              .with(query: hash_excluding(minutes: anything, seconds: anything, hundredths: anything))
              .to_return(
                status: 200,
                body: {
                  timing: {
                    minutes: fixture_mir.minutes,
                    seconds: fixture_mir.seconds,
                    hundredths: fixture_mir.hundredths
                  },
                  score: 900 # (whatever: not checked)
                }.to_json
              )
            get(tools_compute_fin_score_path, xhr: true, params: api_timing_request_params)
          end

          it 'is successful' do
            expect(response).to be_successful
          end
        end

        context 'without valid parameters for any kind of request,' do
          before do
            stub_request(:get, %r{/api/v3/tools/compute_score}i)
              .with(query: hash_excluding(score: anything, minutes: anything, seconds: anything, hundredths: anything))
              .to_return(status: 401, body: '')
            get(tools_compute_fin_score_path, xhr: true)
          end

          it 'is a redirect to root_path' do
            expect(response).to redirect_to(root_path)
          end

          it 'set the flash error message' do
            expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
