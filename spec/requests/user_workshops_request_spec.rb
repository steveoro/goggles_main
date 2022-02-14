# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe 'UserWorkshops', type: :request do
  describe 'GET /index' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(user_workshops_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is a redirect to the root path' do
        get(user_workshops_path)
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash warning about the missing swimmer association' do
        get(user_workshops_path)
        expect(flash[:warning]).to eq(I18n.t('home.my.errors.no_associated_swimmer'))
      end
    end

    context 'with a logged-in user associated to a swimmer,' do
      before do
        user = GogglesDb::User.find([1, 2, 4].sample)
        expect(user).to be_a(GogglesDb::User).and be_valid
        expect(user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        sign_in(user)
      end

      it 'is successful' do
        get(user_workshops_path)
        expect(response).to be_successful
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /show' do
    context 'with a valid row id' do
      let(:fixture_row) { FactoryBot.create(:workshop_with_results) }

      it 'returns http success' do
        get(user_workshop_show_path(fixture_row.id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(user_workshop_show_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
