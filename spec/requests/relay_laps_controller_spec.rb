# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelayLapsController do
  let(:mrr_with_mrs) do
    GogglesDb::MeetingRelayResult.includes(:meeting_relay_swimmers)
                                 .joins(:meeting_relay_swimmers)
                                 .last(250)
                                 .sample
  end

  let(:mrs_with_relay_laps) do
    GogglesDb::RelayLap.includes(:meeting_relay_swimmer)
                       .joins(:meeting_relay_swimmer)
                       .last(250)
                       .sample.parent_result
  end

  let(:random_length) { (50...mrr_with_mrs.event_type.length_in_meters).step(50).to_a.sample }
  let(:fixture_relay_lap) { mrs_with_relay_laps.relay_laps.sample }
  let(:row_index) { (1..8).to_a.sample }

  before do
    expect(mrr_with_mrs).to be_an(GogglesDb::MeetingRelayResult).and be_valid
    expect(mrs_with_relay_laps).to be_an(GogglesDb::MeetingRelaySwimmer).and be_valid
    expect(mrs_with_relay_laps.relay_laps).not_to be_empty
    expect(fixture_relay_lap).to be_a(GogglesDb::RelayLap).and be_valid
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'XHR POST /relay_laps/edit_modal' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        post(
          relay_laps_edit_modal_path(
            result_id: mrr_with_mrs.id,
            result_class: mrr_with_mrs.class.name.split('::').last
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
            relay_laps_edit_modal_path(result_id: 0, result_class: mrr_with_mrs.class.name.split('::').last),
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          post(
            relay_laps_edit_modal_path(result_id: mrr_with_mrs.id, result_class: ''),
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          post(
            relay_laps_edit_modal_path(result_id: mrr_with_mrs.id, result_class: mrr_with_mrs.class.name.split('::').last),
            xhr: true
          )
        end

        it 'is successful' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'POST /relay_laps/edit_modal' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        post(
          relay_laps_edit_modal_path(
            result_id: mrr_with_mrs.id,
            result_class: mrr_with_mrs.class.name.split('::').last
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
          relay_laps_edit_modal_path(
            result_id: mrr_with_mrs.id,
            result_class: mrr_with_mrs.class.name.split('::').last
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

  describe 'XHR POST /relay_lap/create' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        post(
          relay_laps_path(
            result_id: mrr_with_mrs.id,
            result_class: mrr_with_mrs.class.name.split('::').last,
            length_in_meters: random_length
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
            relay_laps_path(
              result_id: 0,
              result_class: mrr_with_mrs.class.name.split('::').last,
              length_in_meters: random_length
            ),
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          post(
            relay_laps_path(
              result_id: mrr_with_mrs.id,
              result_class: '',
              length_in_meters: random_length
            ),
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          post(
            relay_laps_path(
              result_id: mrr_with_mrs.id,
              result_class: mrr_with_mrs.class.name.split('::').last,
              length_in_meters: random_length
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

  describe 'POST /relay_lap/create' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        post(
          relay_laps_path(
            result_id: mrr_with_mrs.id,
            result_class: mrr_with_mrs.class.name.split('::').last,
            length_in_meters: random_length
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
          relay_laps_path(
            result_id: mrr_with_mrs.id,
            result_class: mrr_with_mrs.class.name.split('::').last,
            length_in_meters: random_length
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

  describe 'XHR PUT /relay_lap/:id' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        put(
          relay_lap_path(id: fixture_relay_lap.id),
          params: {
            result_id: { row_index => mrs_with_relay_laps.id },
            result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last },
            length_in_meters: fixture_relay_lap.length_in_meters, minutes_from_start: 0
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
            relay_lap_path(id: [0, fixture_relay_lap.id].sample),
            params: {
              result_id: { row_index => 0 },
              result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last },
              length_in_meters: fixture_relay_lap.length_in_meters,
              minutes_from_start: 0
            },
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          put(
            relay_lap_path(id: fixture_relay_lap.id),
            params: {
              result_id: { row_index => mrs_with_relay_laps.id },
              result_class: { row_index => '' },
              length_in_meters: fixture_relay_lap.length_in_meters,
              minutes_from_start: 0
            },
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          put(
            relay_lap_path(id: fixture_relay_lap.id),
            params: {
              result_id: { row_index => mrs_with_relay_laps.id },
              result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last },
              length_in_meters: fixture_relay_lap.length_in_meters,
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

  describe 'PUT /relay_lap/:id' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        put(
          relay_lap_path(id: fixture_relay_lap.id),
          params: {
            result_id: { row_index => mrs_with_relay_laps.id },
            result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last },
            length_in_meters: fixture_relay_lap.length_in_meters,
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
          relay_lap_path(id: fixture_relay_lap.id),
          params: {
            result_id: { row_index => mrs_with_relay_laps.id },
            result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last },
            length_in_meters: fixture_relay_lap.length_in_meters,
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

  describe 'XHR DELETE /relay_lap/:id' do
    context 'with an unlogged user' do
      it 'returns unauthorized status' do
        delete(
          relay_lap_path(id: fixture_relay_lap.id),
          params: {
            result_id: { row_index => mrs_with_relay_laps.id },
            result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last }
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
            relay_lap_path(id: [0, fixture_relay_lap.id].sample),
            params: {
              result_id: { row_index => 0 },
              result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last }
            },
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and invalid result_class' do
        before do
          delete(
            relay_lap_path(id: fixture_relay_lap.id),
            params: {
              result_id: { row_index => mrs_with_relay_laps.id },
              result_class: { row_index => '' }
            },
            xhr: true
          )
        end

        it 'is successful anyway (renders the dialog with the warning message)' do
          expect(response).to have_http_status(:success)
        end

        it 'sets an invalid request flash warning message' do
          expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
        end
      end

      context 'and valid parameters' do
        before do
          delete(
            relay_lap_path(id: fixture_relay_lap.id),
            params: {
              result_id: { row_index => mrs_with_relay_laps.id },
              result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last }
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

  describe 'DELETE /relay_lap/:id' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        delete(
          relay_lap_path(id: fixture_relay_lap.id),
          params: {
            result_id: { row_index => mrs_with_relay_laps.id },
            result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last }
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
          relay_lap_path(id: fixture_relay_lap.id),
          params: {
            result_id: { row_index => mrs_with_relay_laps.id },
            result_class: { row_index => mrs_with_relay_laps.class.name.split('::').last }
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
