# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LapsController do
  let(:parent_result) do
    [
      GogglesDb::MeetingIndividualResult.last(500).sample,
      GogglesDb::UserResult.last(150).sample
    ].sample
  end

  # Select an abstract lap for the parent result, so that we're sure we have existing
  # lap rows (although not required, makes the test more complete)
  let(:parent_result_with_laps) do
    lap = [
      GogglesDb::Lap.last(500).sample,
      GogglesDb::UserLap.last(500).sample
    ].sample
    lap.parent_result
  end

  let(:fixture_lap) { parent_result_with_laps.laps.sample }
  let(:row_index) { (1..8).to_a.sample }
  let(:random_step) { [25, 33, 50].sample }

  before do
    expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid
    expect(parent_result_with_laps).to be_an(GogglesDb::AbstractResult).and be_valid
    expect(parent_result_with_laps.laps.count).to be_positive
    expect(fixture_lap).to be_an(GogglesDb::AbstractLap).and be_valid
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'XHR POST /laps/edit_modal' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        post(
          laps_edit_modal_path(
            result_id: parent_result.id,
            result_class: parent_result.class.name.split('::').last
          ),
          xhr: true
        )
        expect(response).to have_http_status(:unauthorized)
        # (No redirect since it's an XHR request without sign-in first)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'and invalid result_id' do
        before do
          post(
            laps_edit_modal_path(result_id: 0, result_class: parent_result.class.name.split('::').last),
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          post(
            laps_edit_modal_path(result_id: parent_result.id, result_class: ''),
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          post(
            laps_edit_modal_path(result_id: parent_result.id, result_class: parent_result.class.name.split('::').last),
            xhr: true
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'POST /laps/edit_modal' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        post(
          laps_edit_modal_path(
            result_id: parent_result.id,
            result_class: parent_result.class.name.split('::').last
          )
        )
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
        post(
          laps_edit_modal_path(
            result_id: parent_result.id,
            result_class: parent_result.class.name.split('::').last
          )
        )
      end

      context 'and valid parameters' do
        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'XHR POST /lap/create' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        post(
          laps_path(
            result_id: parent_result.id,
            result_class: parent_result.class.name.split('::').last,
            step: random_step
          ),
          xhr: true
        )
        expect(response).to have_http_status(:unauthorized)
        # (No redirect since it's an XHR request without sign-in first)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'and invalid result_id' do
        before do
          post(
            laps_path(result_id: 0, result_class: parent_result.class.name.split('::').last, step: random_step),
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          post(
            laps_path(result_id: parent_result.id, result_class: '', step: random_step),
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          post(
            laps_path(
              result_id: parent_result.id,
              result_class: parent_result.class.name.split('::').last,
              step: random_step
            ),
            xhr: true
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'POST /lap/create' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        post(
          laps_path(
            result_id: parent_result.id,
            result_class: parent_result.class.name.split('::').last,
            step: random_step
          )
        )
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
        post(
          laps_path(
            result_id: parent_result.id,
            result_class: parent_result.class.name.split('::').last,
            step: random_step
          )
        )
      end

      context 'and valid parameters' do
        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'XHR PUT /lap/:id' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        put(
          lap_path(id: fixture_lap.id),
          params: {
            result_id: { row_index => parent_result_with_laps.id },
            result_class: { row_index => parent_result_with_laps.class.name.split('::').last },
            length_in_meters: fixture_lap.length_in_meters, minutes_from_start: 0
          },
          xhr: true
        )
        expect(response).to have_http_status(:unauthorized)
        # (No redirect since it's an XHR request without sign-in first)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'and invalid id or result_id' do
        before do
          put(
            lap_path(id: [0, fixture_lap.id].sample),
            params: {
              result_id: { row_index => 0 },
              result_class: { row_index => parent_result_with_laps.class.name.split('::').last },
              length_in_meters: fixture_lap.length_in_meters,
              minutes_from_start: 0
            },
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          put(
            lap_path(id: fixture_lap.id),
            params: {
              result_id: { row_index => parent_result_with_laps.id },
              result_class: { row_index => '' },
              length_in_meters: fixture_lap.length_in_meters,
              minutes_from_start: 0
            },
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          put(
            lap_path(id: fixture_lap.id),
            params: {
              result_id: { row_index => parent_result_with_laps.id },
              result_class: { row_index => parent_result_with_laps.class.name.split('::').last },
              length_in_meters: fixture_lap.length_in_meters,
              minutes_from_start: 0
            },
            xhr: true
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'PUT /lap/:id' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        put(
          lap_path(id: fixture_lap.id),
          params: {
            result_id: { row_index => parent_result_with_laps.id },
            result_class: { row_index => parent_result_with_laps.class.name.split('::').last },
            length_in_meters: fixture_lap.length_in_meters,
            minutes_from_start: 0
          }
        )
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
        put(
          lap_path(id: fixture_lap.id),
          params: {
            result_id: { row_index => parent_result_with_laps.id },
            result_class: { row_index => parent_result_with_laps.class.name.split('::').last },
            length_in_meters: fixture_lap.length_in_meters,
            minutes_from_start: 0
          }
        )
      end

      context 'and valid parameters' do
        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'XHR DELETE /lap/:id' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        delete(
          lap_path(id: fixture_lap.id),
          params: {
            result_id: { row_index => parent_result_with_laps.id },
            result_class: { row_index => parent_result_with_laps.class.name.split('::').last }
          },
          xhr: true
        )
        expect(response).to have_http_status(:unauthorized)
        # (No redirect since it's an XHR request without sign-in first)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'and invalid id or result_id' do
        before do
          delete(
            lap_path(id: [0, fixture_lap.id].sample),
            params: {
              result_id: { row_index => 0 },
              result_class: { row_index => parent_result_with_laps.class.name.split('::').last }
            },
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          delete(
            lap_path(id: fixture_lap.id),
            params: {
              result_id: { row_index => parent_result_with_laps.id },
              result_class: { row_index => '' }
            },
            xhr: true
          )
        end

        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          delete(
            lap_path(id: fixture_lap.id),
            params: {
              result_id: { row_index => parent_result_with_laps.id },
              result_class: { row_index => parent_result_with_laps.class.name.split('::').last }
            },
            xhr: true
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'DELETE /lap/:id' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        delete(
          lap_path(id: fixture_lap.id),
          params: {
            result_id: { row_index => parent_result_with_laps.id },
            result_class: { row_index => parent_result_with_laps.class.name.split('::').last }
          }
        )
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
        delete(
          lap_path(id: fixture_lap.id),
          params: {
            result_id: { row_index => parent_result_with_laps.id },
            result_class: { row_index => parent_result_with_laps.class.name.split('::').last }
          }
        )
      end

      context 'and valid parameters' do
        it 'is a redirect to the root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
