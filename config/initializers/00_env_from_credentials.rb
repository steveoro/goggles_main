# frozen_string_literal: true

# [Steve A.] === Note: ===
# This allows to set sensitive ENV variables directly from same-named
# keys from the encrypted credentials in order to have a single place
# for secrets.
#
# For this reason, it's imperative that the initializer file name starts
# with a number so that this gets executed before any other initializer
# that may need those ENV values.
#
%w[
  GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET
  FACEBOOK_APP_ID FACEBOOK_APP_SECRET
  TWITTER_API_KEY TWITTER_API_SECRET
].each do |env_key|
  ENV[env_key] = Rails.application.credentials.send(env_key).to_s if Rails.application.credentials.send(env_key).to_s.present?
end
