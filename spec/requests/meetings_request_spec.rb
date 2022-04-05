# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe 'Meetings', type: :request do
  describe 'GET /index' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(meetings_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is a redirect to the root path' do
        get(meetings_path)
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash warning about the missing swimmer association' do
        get(meetings_path)
        expect(flash[:warning]).to eq(I18n.t('home.my.errors.no_associated_swimmer'))
      end
    end

    context 'with a logged-in user associated to a swimmer,' do
      before do
        user = GogglesDb::User.includes(swimmer: [:gender_type])
                              .joins(swimmer: [:gender_type])
                              .first(50)
                              .sample
        expect(user).to be_a(GogglesDb::User).and be_valid
        expect(user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        sign_in(user)
      end

      it 'is successful' do
        get(meetings_path)
        expect(response).to be_successful
      end

      context 'when filtering data by :meeting_date,' do
        it 'is successful' do
          get(meetings_path(meetings_grid: { meeting_date: '2019-12-15' }))
          expect(response).to be_successful
        end
      end

      context 'when filtering data by :meeting_name,' do
        it 'is successful' do
          get(meetings_path(meetings_grid: { meeting_name: 'Riccione' }))
          expect(response).to be_successful
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /show/:id' do
    context 'with a valid row id' do
      let(:meeting_id) { GogglesDb::Meeting.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(meeting_show_path(meeting_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(meeting_show_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /for_swimmer/:id' do
    context 'with a valid row id' do
      let(:swimmer_id) { GogglesDb::Swimmer.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(meetings_for_swimmer_path(swimmer_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(meetings_for_swimmer_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /for_team/:id' do
    context 'with a valid row id' do
      let(:team_id) { GogglesDb::Team.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(meetings_for_swimmer_path(team_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(meetings_for_team_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
