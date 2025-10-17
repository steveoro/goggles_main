# frozen_string_literal: true

# Configure Warden test mode for proper cleanup between scenarios
# (similar to RSpec configuration in spec/rails_helper.rb)
Before do
  Warden.test_mode!
end

After do
  Warden.test_reset!
end

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
