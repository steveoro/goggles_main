# frozen_string_literal: true

# Configure Warden test mode for proper cleanup between scenarios
# (similar to RSpec configuration in spec/rails_helper.rb)

# Enable Warden test mode at the start of the test suite
BeforeAll do
  Warden.test_mode!
end

# CRITICAL: Ensure clean state BEFORE each scenario starts
# This is essential in CI with parallel execution where sessions can persist
Before do
  # Reset Warden session state
  Warden.test_reset!

  # Reset Capybara session to clear browser cookies (Selenium drivers)
  Capybara.reset_session!

  # For Selenium drivers: explicitly delete all cookies (if browser is active)
  begin
    page.driver.browser.manage.delete_all_cookies if page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:manage)
  rescue StandardError => e
    # Ignore errors if browser isn't initialized yet
    Rails.logger.debug { "Cookie deletion skipped (browser not ready): #{e.message}" }
  end
end

# Also reset after each scenario for good measure
After do
  Warden.test_reset!
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
