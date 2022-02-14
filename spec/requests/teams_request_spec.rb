# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe 'Teams', type: :request do
  let(:fixture_row) { GogglesDb::Team.first(50).sample }

  describe 'GET /show' do
    context 'with a valid row id' do
      it 'returns http success' do
        get(team_show_path(fixture_row.id))
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

  describe 'GET /current_swimmers' do
    let(:fixture_user) { FactoryBot.create(:user) }

    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(team_current_swimmers_path(fixture_row.id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user but with a non-existing team ID,' do
      before { sign_in(fixture_user) }

      it 'is a redirect to the root path' do
        get(team_current_swimmers_path(-1))
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash warning about the invalid request' do
        get(team_current_swimmers_path(-1))
        expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
      end
    end

    context 'with a logged-in user and an existing team ID,' do
      before { sign_in(fixture_user) }

      it 'is successful' do
        get(team_current_swimmers_path(fixture_row.id))
        expect(response).to be_successful
      end
    end
  end
end
