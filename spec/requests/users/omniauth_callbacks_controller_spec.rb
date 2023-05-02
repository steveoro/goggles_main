# frozen_string_literal: true

require 'rails_helper'

# [Steve A.] Although this should be more of an integration test, we keep this here
# as an example for correctly mocking OAuth requests in case of any future Cucumber tests.
# We'll just stick to plain route checking for RSpec request examples.
#
# rubocop:disable Metrics/BlockLength
RSpec.describe Users::OmniauthCallbacksController do
  let(:existing_user) { GogglesDb::User.first(50).sample }
  let(:new_user) { FactoryBot.build(:user) }

  # Prepares the resulting authorization Hash given the parameters.
  #
  # == Params
  # - provider: any provider name
  # - uid: a unique ID string
  # - user: the user instance requesting authorization
  #
  # == Params
  # an OmniAuth::AuthHash that wraps the user_instance data
  #
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

  before do
    expect(existing_user).to be_a(GogglesDb::User).and be_valid

    # Use :default key to prepare default AuthHash response (individual provider keys can still
    # be defined as overrides):
    # (@see https://github.com/omniauth/omniauth/wiki/Integration-Testing)
    # OmniAuth.config.mock_auth[:default] = valid_auth('facebook', '1235456', existing_user)
    # OmniAuth.config.mock_auth[:google_oauth2] = valid_auth('google_oauth2', '1235456', existing_user)
    # OmniAuth.config.mock_auth[:facebook] = valid_auth('facebook', '1235456', new_user)

    # With test_mode on, a request to /auth/provider will redirect immediately
    # to /auth/provider/callback returning the AuthHash for that provider:
    OmniAuth.config.test_mode = true

    # Use add_mock to quickly add new AuthHash to be merged with the :default, like this:
    # OmniAuth.config.add_mock(:google_oauth2, {:uid => '12345'})

    # Setting a provider's mock to a symbol instead of a hash, it will fail with that message:
    # OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    # Clean-up mocks in-between tests by setting them to nil:
    # OmniAuth.config.mock_auth[:google_oauth2] = nil

    # Setup controller mappings & auth before tests (old RSpec @request.env[] settings):
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    # Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  describe 'POST /auth/:provider' do
    # [Steve, 20210806] ('google_oauth2' removed for the time being)
    %i[facebook].each do |provider|
      context "returning valid credentials for an existing, validated user (#{provider})," do
        before do
          OmniAuth.config.mock_auth[provider] = valid_auth(
            provider.to_s,
            (GogglesDb::User.last.id + 1).to_s,
            existing_user
          )
          Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[provider]
          if provider == :facebook
            post(user_facebook_omniauth_authorize_path)
            # else
            #   post(user_google_oauth2_omniauth_callback_path)
          end
        end

        it 'redirects to default (for event: authentication)' do
          if provider == :facebook
            # [Steve A.] FB config currently "stops gracefully" in the middle of the callback chain probably due to
            # an error in above setup
            expect(response).to redirect_to(user_facebook_omniauth_callback_path)
          else
            expect(response).to redirect_to(root_path)
          end
        end
        # (Read the previous note ^^^)

        it 'sets the flash to the notice msg for a successful authentication' do
          pending("Currently FB omniauth isn't setup properly, so this check is skipped")
          expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: provider.to_s.titleize))
        end
      end

      context "returning valid credentials for a new user (#{provider})," do
        before do
          OmniAuth.config.mock_auth[provider] = valid_auth(
            provider.to_s,
            (GogglesDb::User.last.id + 1).to_s,
            new_user
          )
          Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[provider]
          if provider == :facebook
            post(user_facebook_omniauth_authorize_path)
            # else
            #   post(user_google_oauth2_omniauth_callback_path)
          end
        end

        it "redirects to #{provider}/auth/callback" do
          if provider == :facebook
            # [Steve A.] FB config currently "stops gracefully" in the middle of the callback chain probably due to
            # an error in above setup
            expect(response).to redirect_to(user_facebook_omniauth_callback_path)
          else
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end

    context 'returning with an OAuth failure,' do
      before do
        # [Steve, 20210806] (google_oauth2 removed for the time being)
        # OmniAuth.config.mock_auth[:google_oauth2] = nil
        OmniAuth.config.mock_auth[:facebook] = nil
        Rails.application.env_config['omniauth.auth'] = :invalid_credentials
        post(user_facebook_omniauth_callback_path) # (any provider path will suffice)
      end

      it 'redirects to the sign-up path' do
        expect(response).to redirect_to(new_user_registration_url)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
