# frozen_string_literal: true

# Setup test mode for Omniauth
Before('@omniauth') do
  OmniAuth.config.test_mode = true
  Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
end

# Clean-up test mocks
After('@omniauth') do
  OmniAuth.config.mock_auth[:default] = nil
  OmniAuth.config.mock_auth[:google_oauth2] = nil
  OmniAuth.config.mock_auth[:facebook] = nil
  OmniAuth.config.mock_auth[:twitter] = nil
end
