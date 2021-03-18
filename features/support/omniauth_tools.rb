# frozen_string_literal: true

#
# == Capybara Omniauth helpers support module
#
# Use the @omniauth tag for each example that requires test mode.
# (@see features/support/hooks.rb)

# === Notes on usage ===
#
# With test_mode on, a request to /auth/provider will redirect immediately
# to /auth/provider/callback returning the AuthHash for that provider:
# OmniAuth.config.test_mode = true
#
# Remember to set mocks before testing each request, like this:
#
# OmniAuth.config.mock_auth[:google_oauth2] = valid_auth('google_oauth2', '1235456', existing_user)
# OmniAuth.config.mock_auth[:facebook] = valid_auth('facebook', '1235456', new_user)

# Use :default key to prepare default AuthHash response (individual provider keys can still
# be defined as overrides):
# (@see https://github.com/omniauth/omniauth/wiki/Integration-Testing)
#
# OmniAuth.config.mock_auth[:default] = valid_auth('facebook', '1235456', existing_user)

# Use add_mock to quickly add new AuthHash to be merged with the :default, like this:
#
# OmniAuth.config.add_mock(:google_oauth2, {:uid => '12345'})

# Setting a provider's mock to a symbol instead of a hash, it will fail with that message:
#
# OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

# Clean-up mocks in-between tests by setting them to nil:
#
# OmniAuth.config.mock_auth[:google_oauth2] = nil
module OmniAuthTools
  # Prepares the resulting authorization Hash given the parameters.
  #
  # == Params
  # - provider_name: any provider name
  # - uid: a unique ID string
  # - user_instance: the user requesting authorization
  #
  # == Params
  # an OmniAuth::AuthHash that wraps the user_instance data
  #
  def valid_auth(provider_name, uid, user_instance)
    OmniAuth::AuthHash.new(
      {
        provider: provider_name,
        uid: uid,
        info: {
          email: user_instance.email,
          name: user_instance.name,
          first_name: user_instance.first_name,
          last_name: user_instance.last_name,
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
            name: user_instance.description,
            first_name: user_instance.first_name,
            last_name: user_instance.last_name
            # (...not used...)
          }
        }
      }
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end

World(OmniAuthTools) if respond_to?(:World)
