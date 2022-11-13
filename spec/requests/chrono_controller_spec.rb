# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChronoController, type: :request do
  describe 'GET /chrono/index' do
    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        get(chrono_new_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
        get(chrono_new_path)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /chrono/download/:id' do
    let(:fixture_user) { GogglesDb::User.first(50).sample }
    let(:fixture_row) do
      master_row = FactoryBot.create(
        :import_queue,
        user: fixture_user,
        request_data: {
          'target_entity': 'Lap',
          'lap': {
            'label': "01'26\"59",
            'order': 4,
            'length_in_meters': 100,
            'minutes_from_start': 1,
            'seconds_from_start': 26,
            'hundredths_from_start': 59
          }.to_json
        }
      )
      FactoryBot.create_list(:import_queue, 3, user: fixture_user, import_queue: master_row)
      expect(GogglesDb::ImportQueue.count).to be >= 4
      master_row
    end

    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        get(chrono_download_path(fixture_row.id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        expect(fixture_user).to be_a(GogglesDb::User).and be_valid
        expect(fixture_row).to be_a(GogglesDb::ImportQueue).and be_valid
        sign_in(fixture_user)
      end

      context 'with an invalid :id parameter,' do
        before { get(chrono_download_path(id: -1)) }

        it 'redirects to /chrono/index' do
          expect(response).to redirect_to(chrono_index_path)
        end

        it 'sets a flash error message about the wrong/missing parameter' do
          expect(flash[:error]).to eq(I18n.t('chrono.messages.error.invalid_parameters'))
        end
      end

      context 'with a valid :id parameter,' do
        before { get(chrono_download_path(id: fixture_row.id)) }

        it 'downloads a JSON text data file' do
          expect(response.headers['Content-Type']).to eq('text/json')
          expect(response.headers['Content-Disposition']).to include('attachment')
        end

        it 'sends a data file containing the JSON request data of the chosen rows' do
          # Limiting just to the first row to be quick::
          expect(response.body).to be_present && include(fixture_row.request_data)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /chrono/new' do
    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        get(chrono_new_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
        get(chrono_new_path)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /chrono/rec' do
    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        post(chrono_rec_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'without some of the required parameters,' do
        [
          { 'rec_type' => 1 },
          { 'meeting_label' => 'Whatever you chose' },
          { 'user_workshop_label' => 'Whatever you chose 2' }
        ].each do |partial_params|
          before { post(chrono_rec_path, params: partial_params) }

          it 'redirects to /chrono/new' do
            expect(response).to redirect_to(chrono_new_path)
          end

          it 'sets a flash error message about the missing parameter' do
            expect(flash[:error]).to eq(I18n.t('chrono.messages.error.missing_meeting_or_workshop_name'))
          end
        end
      end

      context 'with valid timing rec parameters,' do
        before { post(chrono_rec_path, params: { 'rec_type' => 1, 'meeting_label' => 'Just a test' }) }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /chrono/commit' do
    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        post(chrono_commit_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      let(:fixture_user) { GogglesDb::User.first(50).sample }

      before do
        expect(fixture_user).to be_a(GogglesDb::User).and be_valid
        sign_in(fixture_user)
      end

      context 'without some of the required parameters,' do
        [
          { json_header: { 'target_entity' => 'Lap' }.to_json },
          { json_payload: { order: 1, minutes: 0, seconds: 45, hundredths: 10 }.to_json }
        ].each do |partial_params|
          before { post(chrono_commit_path, params: partial_params) }

          it 'redirects to /chrono/new' do
            expect(response).to redirect_to(chrono_new_path)
          end

          it 'sets a flash error message about the missing parameter' do
            expect(flash[:error]).to eq(I18n.t('chrono.messages.error.commit_missing_parameters'))
          end
        end
      end

      context 'with some invalid timing commit parameters,' do
        let(:invalid_request_params) do
          {
            json_header: { 'target_entity' => 'Lap' }.to_json,
            json_payload: { order: 1 }.to_json
          }
        end

        it 'yields a server error' do
          expect { post(chrono_commit_path, params: invalid_request_params) }
            .to raise_error(ArgumentError)
        end
      end

      context 'with valid timing commit parameters,' do
        # Domain definition:
        let(:fixture_swimmer) { GogglesDb::Swimmer.first(150).sample }
        let(:fixture_event) { GogglesDb::EventsByPoolType.eventable.individuals.sample.event_type }
        # Minimalistic example:
        let(:min_request_header) do
          {
            'target_entity' => 'Lap',
            'lap' => {
              'swimmer' => { 'complete_name' => fixture_swimmer.complete_name },
              'meeting_individual_result' => {
                'user_id' => fixture_user.id,
                'event_type_id' => fixture_event.id
              }
            }
          }
        end

        before do
          expect(fixture_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
          expect(fixture_event).to be_an(GogglesDb::EventType).and be_valid
          expect(min_request_header).to be_a(Hash).and be_present
          post(
            chrono_commit_path,
            params: {
              json_header: min_request_header.to_json,
              json_payload: { order: 1, minutes: 0, seconds: 45, hundredths: 10 }.to_json
            }
          )
        end

        it 'redirects to /chrono/index' do
          expect(response).to redirect_to(chrono_index_path)
        end

        it 'sets a positive flash notice message' do
          expect(flash[:notice]).to eq(I18n.t('chrono.messages.post_done'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'DELETE /chrono/delete/:id' do
    context 'with an unlogged user,' do
      it 'is a redirect to the login path' do
        delete(chrono_delete_path(id: 1))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      let(:fixture_user) { GogglesDb::User.first(50).sample }
      let(:deletable_row) { FactoryBot.create(:import_queue, user: fixture_user) }

      before do
        expect(fixture_user).to be_a(GogglesDb::User).and be_valid
        expect(deletable_row).to be_a(GogglesDb::ImportQueue).and be_valid
        sign_in(fixture_user)
      end

      context 'with an invalid :id parameter,' do
        before { delete(chrono_delete_path(id: -1)) }

        it 'redirects to /chrono/index' do
          expect(response).to redirect_to(chrono_index_path)
        end

        it 'sets a flash error message about the wrong/missing parameter' do
          expect(flash[:error]).to eq(I18n.t('chrono.messages.error.delete_invalid_parameters'))
        end
      end

      context 'with a valid :id parameter,' do
        before { delete(chrono_delete_path(id: deletable_row.id)) }

        it 'redirects to /chrono/index' do
          expect(response).to redirect_to(chrono_index_path)
        end

        it 'sets a positive flash notice message' do
          expect(flash[:notice]).to eq(I18n.t('chrono.messages.delete_done'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
