# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Chronos', type: :request do
  describe 'GET /chrono/index' do
    context 'for an unlogged user,' do
      it 'is a redirect to the login path' do
        get(chrono_new_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a logged-in user' do
      before(:each) do
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

  describe 'GET /chrono/new' do
    context 'for an unlogged user,' do
      it 'is a redirect to the login path' do
        get(chrono_new_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a logged-in user' do
      before(:each) do
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

  # describe 'POST /chrono/rec' do
  #   context 'for an unlogged user,' do
  #     it 'is a redirect to the login path' do
  #       post(chrono_rec_path)
  #       expect(response).to redirect_to(new_user_session_path)
  #     end
  #   end

  #   context 'for a logged-in user' do
  #     before(:each) do
  #       user = GogglesDb::User.first(50).sample
  #       sign_in(user)
  #       post(chrono_rec_path)
  #     end
  #     # TODO: test failing w/ flash error
  #     # TODO: test success w/ flash notice
  #     it 'returns http success' do
  #       expect(response).to have_http_status(:success)
  #     end
  #   end
  # end
  #-- -------------------------------------------------------------------------
  #++

  # describe 'POST /chrono/commit' do
  #   context 'for an unlogged user,' do
  #     it 'is a redirect to the login path' do
  #       post(chrono_commit_path)
  #       expect(response).to redirect_to(new_user_session_path)
  #     end
  #   end

  #   context 'for a logged-in user' do
  #     before(:each) do
  #       user = GogglesDb::User.first(50).sample
  #       sign_in(user)
  #       post(chrono_commit_path)
  #     end
  #     context 'with valid & successful timing rec parameters,' do
  #       it 'redirects to /chrono/index' do
  #         expect(response).to redirect_to(chrono_index_path)
  #       end
  #       # TODO: it enqueues the recording
  #       # TODO: test success w/ flash notice
  #     end
  #     context 'with valid timing rec parameters,' do
  #       # TODO
  #     end
  #     # TODO: test failing w/ flash error
  #   end
  # end
  #-- -------------------------------------------------------------------------
  #++
end
