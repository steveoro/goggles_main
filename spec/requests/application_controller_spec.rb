# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  # Request Locale setter
  [nil, :it, :en, :invalid].each do |locale_sym|
    context "when setting the locale parameter as '#{locale_sym}'," do
      describe 'GET /' do
        before { get(root_path, params: { locale: locale_sym }) }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the I18n locale' do
          expected_locale = locale_sym || :it
          expected_locale = I18n.default_locale if locale_sym == :invalid
          expect(I18n.locale).to eq(expected_locale)
        end
      end
    end
  end

  describe 'anonymous request throttling' do
    let(:test_ip) { '127.0.0.1' }
    let(:stats_route) { "REQ-#{test_ip}" }

    before do
      # Ensure the setting has a known default value
      row = GogglesDb::AppParameter.versioning_row
      row.settings(:app).max_anonymous_req = GogglesDb::AppParameter::DEFAULT_MAX_ANONYMOUS_REQ
      row.save!
    end

    context 'when the daily count is under the bias' do
      before do
        GogglesDb::APIDailyUse
          .find_or_initialize_by(route: stats_route, day: Time.zone.today)
          .update!(count: 10)
      end

      it 'allows normal browsing' do
        get(root_path, env: { 'REMOTE_ADDR' => test_ip })
        expect(response).to have_http_status(:success)
      end

      it 'tracks the user agent for the request' do
        expect do
          get(
            root_path,
            env: { 'REMOTE_ADDR' => test_ip, 'HTTP_USER_AGENT' => 'Main-Test/1.0' }
          )
        end.to change {
          GogglesDb::APIDailyUseAgent.where(user_agent: 'Main-Test/1.0', day: Time.zone.today).count
        }.by(1)
      end

      it 'stores a missing user agent as unknown' do
        expect do
          get(root_path, env: { 'REMOTE_ADDR' => test_ip })
        end.to change {
          GogglesDb::APIDailyUseAgent.where(user_agent: 'unknown', day: Time.zone.today).count
        }.by(1)
      end
    end

    context 'when the daily count exceeds the bias and no user is signed in' do
      before do
        GogglesDb::APIDailyUse
          .find_or_initialize_by(route: stats_route, day: Time.zone.today)
          .update!(count: GogglesDb::AppParameter::DEFAULT_MAX_ANONYMOUS_REQ + 1)
      end

      it 'redirects to the too_many_requests page' do
        get(root_path, env: { 'REMOTE_ADDR' => test_ip })
        expect(response).to redirect_to(home_too_many_requests_path)
      end
    end

    context 'when the daily count exceeds the bias but a user is signed in' do
      before do
        GogglesDb::APIDailyUse
          .find_or_initialize_by(route: stats_route, day: Time.zone.today)
          .update!(count: GogglesDb::AppParameter::DEFAULT_MAX_ANONYMOUS_REQ + 1)
        sign_in(FactoryBot.create(:user))
      end

      it 'allows normal browsing (no throttle)' do
        get(root_path, env: { 'REMOTE_ADDR' => test_ip })
        expect(response).to have_http_status(:success)
      end
    end

    context 'when browsing the too_many_requests page itself' do
      before do
        GogglesDb::APIDailyUse
          .find_or_initialize_by(route: stats_route, day: Time.zone.today)
          .update!(count: GogglesDb::AppParameter::DEFAULT_MAX_ANONYMOUS_REQ + 1)
      end

      it 'does not redirect (no loop)' do
        get(home_too_many_requests_path, env: { 'REMOTE_ADDR' => test_ip })
        expect(response).to have_http_status(:success)
      end
    end

    context 'when accessing a Devise controller' do
      before do
        GogglesDb::APIDailyUse
          .find_or_initialize_by(route: stats_route, day: Time.zone.today)
          .update!(count: GogglesDb::AppParameter::DEFAULT_MAX_ANONYMOUS_REQ + 1)
      end

      it 'is not throttled (sign-in page accessible)' do
        get(new_user_session_path, env: { 'REMOTE_ADDR' => test_ip })
        expect(response).to have_http_status(:success)
      end
    end
  end
end
