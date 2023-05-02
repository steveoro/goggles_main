# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarsController do
  describe 'GET /current' do
    context 'for an unlogged user' do
      it 'redirects to the login path' do
        get(calendars_current_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a valid signed-in current user,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is successful' do
        get(calendars_current_path)
        expect(response).to be_successful
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /starred' do
    context 'for an unlogged user' do
      it 'redirects to the login path' do
        get(calendars_starred_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a valid signed-in current user,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is successful' do
        get(calendars_starred_path)
        expect(response).to be_successful
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /starred_map' do
    context 'for an unlogged user' do
      it 'redirects to the login path' do
        get(calendars_starred_map_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a valid signed-in current user,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is successful' do
        get(calendars_starred_map_path)
        expect(response).to be_successful
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
