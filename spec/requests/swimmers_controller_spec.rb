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

  describe 'GET /history/:id' do
    let(:event_type_id) { GogglesDb::EventType.all_individuals.pluck(:id).sample }

    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(swimmer_history_path(id: fixture_row_id, event_type_id: event_type_id))
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
          get(swimmer_history_path(id: fixture_row_id, event_type_id: event_type_id))
          expect(response).to have_http_status(:success)
        end
      end

      context 'with an invalid swimmer id' do
        before { get(swimmer_history_path(id: -1, event_type_id: event_type_id)) }

        it_behaves_like('invalid row id GET request')
      end

      context 'with an invalid event_type_id' do
        before { get(swimmer_history_path(id: fixture_row_id, event_type_id: -1)) }

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
