# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'APISessions', type: :request do
  describe 'POST /jwt' do
    context 'for an unlogged user requesting JSON format' do
      it 'is a redirect to the login path' do
        post(api_sessions_jwt_path(format: :json))
        expect(response).to be_unauthorized
      end
    end

    context 'for an unlogged user making a non-JSON request' do
      it 'is a redirect to the login path' do
        post(api_sessions_jwt_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'requesting plain HTML,' do
        before { post(api_sessions_jwt_path) }

        it 'is a redirect to root_path' do
          expect(response).to redirect_to(root_path)
        end

        it 'set the flash error message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'requesting JSON format,' do
        before { post(api_sessions_jwt_path(format: :json)) }

        it 'is successful' do
          expect(response).to be_successful
        end

        it 'returns the new JWT as JSON' do
          json = JSON.parse(response.body)
          expect(json).to have_key('jwt')
          expect(json['jwt']).to be_present
        end
      end
    end
  end
end
