# frozen_string_literal: true

require 'rails_helper'

# [Steve A.] Although this should be more of an integration test, we keep this here
# as an example for correctly mocking OAuth requests in case of any future Cucumber tests.
# We'll just stick to plain route checking for RSpec request examples.
RSpec.describe 'Users::OmniauthCallbacks', type: :request do
  let(:existing_user) { GogglesDb::User.first(50).sample }
  let(:new_user) { FactoryBot.build(:user) }

  # Helper for defining a valid OAuth token given user credentials
  # Returns an OmniAuth::AuthHash
  def valid_auth(provider, uid, user)
    OmniAuth::AuthHash.new(
      {
        provider: provider,
        uid: uid,
        info: {
          email: user.email,
          name: user.name,
          first_name: user.first_name,
          last_name: user.last_name,
          image: nil,
          verified: true
        },
        credentials: {
          token: 'ABCDEFGHIJKLMNO', # actual OAuth 2.0 access_token
          expires_at: 1_321_747_205, # decode from Unix timestamp
          expires: true
        },
        extra: {
          raw_info: {
            id: uid,
            name: user.description,
            first_name: user.first_name,
            last_name: user.last_name
            # (...not used...)
          }
        }
      }
    )
  end

  before(:each) do
    expect(existing_user).to be_a(GogglesDb::User).and be_valid

    # Use :default key to prepare default AuthHash response (individual provider keys can still
    # be defined as overrides):
    # (@see https://github.com/omniauth/omniauth/wiki/Integration-Testing)
    OmniAuth.config.mock_auth[:default] = valid_auth('twitter', '123545', existing_user)
    OmniAuth.config.mock_auth[:facebook] = valid_auth('facebook', '1235456', new_user)

    # With test_mode on, a request to /auth/provider will redirect immediately
    # to /auth/provider/callback returning the AuthHash for that provider:
    OmniAuth.config.test_mode = true

    # Use add_mock to quickly add new AuthHash to be merged with the :default, like this:
    # OmniAuth.config.add_mock(:twitter, {:uid => '12345'})

    # Setting a provider's mock to a symbol instead of a hash, it will fail with that message:
    # OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

    # Clean-up mocks in-between tests by setting them to nil:
    # OmniAuth.config.mock_auth[:twitter] = nil

    # Setup controller mappings & auth before tests (old RSpec @request.env[] settings):
    # Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    # Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
  end

  describe 'POST /auth/:provider' do
    context 'returning valid credentials for an existing, activated user,' do
      before(:each) do
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
        post(user_twitter_omniauth_authorize_path)
      end
      it 'redirects to :provider/auth/callback' do
        expect(response).to redirect_to(user_twitter_omniauth_callback_path)
      end
    end

    context 'returning valid credentials for a new existing user,' do
      before(:each) do
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
        post(user_facebook_omniauth_authorize_path)
      end
      it 'redirects to :provider/auth/callback' do
        expect(response).to redirect_to(user_facebook_omniauth_callback_path)
      end
    end

    context 'returning with an OAuth failure,' do
      before(:each) do
        OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
        Rails.application.env_config['omniauth.auth'] = :invalid_credentials
        post(user_twitter_omniauth_authorize_path)
      end
      it 'redirects to :provider/auth/callback anyway' do
        expect(response).to redirect_to(user_twitter_omniauth_callback_path)
      end
    end
  end
end
