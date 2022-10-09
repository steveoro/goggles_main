# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendars', type: :request do
  let(:season_without_calendars) do
    # TODO
  end

  let(:season_with_calendars) do
    # TODO
  end

  let(:fixture_calendars) do
    # TODO
  end

  describe 'GET /season' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(calendars_season_path(1)) # season doesn't matter here
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a valid logged-in user chosing a season with calendars in it,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      xit 'is successful' do
        # TODO
        # get(calendars_season_path())
      end
    end

    context 'with a valid logged-in user chosing a season with NO calendars in it,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      xit 'is a redirect to the root page' do
        # TODO
        # get(calendars_season_path())
      end

      xit 'sets a flash error' do
        get(calendars_season_path)
        expect(flash[:error]).to eq(I18n.t('search_view.errors.invalid_request'))
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
