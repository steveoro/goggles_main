# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe TaggingsController do
  let(:fixture_meeting_id) { GogglesDb::Meeting.last(100).sample.id }
  let(:fixture_team_id) { GogglesDb::Team.first(100).sample.id }

  describe 'POST /by_user' do
    context 'for an unlogged user' do
      it 'redirects to the login path' do
        post(taggings_by_user_path(meeting_id: fixture_meeting_id))
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a valid signed-in current user,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      context 'making a plain HTML request,' do
        before { post(taggings_by_user_path(meeting_id: fixture_meeting_id)) }

        it 'redirects to root_path (fallback) without warning' do
          expect(response).to redirect_to(root_path)
          expect(flash[:warning]).to be_nil
        end
      end

      context 'making a Turbo Stream request with valid parameters,' do
        before do
          post(
            taggings_by_user_path(meeting_id: fixture_meeting_id),
            headers: { 'ACCEPT' => Mime[:turbo_stream].to_s }
          )
        end

        it 'is successful' do
          expect(response).to be_successful
        end
      end

      context 'making a Turbo Stream request with missing or invalid parameters,' do
        before do
          post(
            taggings_by_user_path(meeting_id: 0),
            headers: { 'ACCEPT' => Mime[:turbo_stream].to_s }
          )
        end

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /by_team' do
    context 'for an unlogged user' do
      it 'redirects to the login path' do
        post(taggings_by_team_path, params: { meeting_id: fixture_meeting_id, team_id: fixture_team_id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a valid signed-in current user,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      context 'making a plain HTML request,' do
        before { post(taggings_by_team_path, params: { meeting_id: fixture_meeting_id, team_id: fixture_team_id }) }

        it 'redirects to root_path (fallback) without warning' do
          expect(response).to redirect_to(root_path)
          expect(flash[:warning]).to be_nil
        end
      end

      context 'making a Turbo Stream request with valid parameters,' do
        before do
          post(
            taggings_by_team_path,
            params: { meeting_id: fixture_meeting_id, team_id: fixture_team_id },
            headers: { 'ACCEPT' => Mime[:turbo_stream].to_s }
          )
        end

        it 'is successful' do
          expect(response).to be_successful
        end
      end

      context 'making a Turbo Stream request with missing or invalid parameters,' do
        # (no team_id parameter)
        before do
          post(
            taggings_by_team_path,
            params: { meeting_id: fixture_meeting_id },
            headers: { 'ACCEPT' => Mime[:turbo_stream].to_s }
          )
        end

        it_behaves_like('invalid row id GET request')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
