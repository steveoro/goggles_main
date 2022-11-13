# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe TeamsController, type: :request do
  let(:fixture_row_id) { GogglesDb::Team.first(100).pluck(:id).sample }

  describe 'GET /show/:id' do
    context 'with a valid row id' do
      it 'returns http success' do
        get(team_show_path(fixture_row_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(team_show_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /current_swimmers/:id' do
    let(:fixture_user) { FactoryBot.create(:user) }

    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(team_current_swimmers_path(fixture_row_id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before { sign_in(fixture_user) }

      context 'with a valid row id' do
        it 'is successful' do
          get(team_current_swimmers_path(fixture_row_id))
          expect(response).to have_http_status(:success)
        end
      end

      context 'with an invalid row id' do
        before { get(team_current_swimmers_path(-1)) }

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
