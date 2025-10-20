# frozen_string_literal: true

# Configure Warden test mode for proper cleanup between scenarios
# (similar to RSpec configuration in spec/rails_helper.rb)
#
# Note: Warden.test_mode! should be called once per test suite, not per scenario.
# Calling it before every scenario can interfere with session management.
BeforeAll do
  Warden.test_mode!
end

# Reset Warden and Capybara session after each scenario to ensure clean state
After do
  Warden.test_reset!
  # Also reset Capybara session to clear browser cookies in Selenium drivers
  Capybara.reset_session!
end

AfterAll do
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
