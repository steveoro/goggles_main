# frozen_string_literal: true

# Configure Warden test mode for proper cleanup between scenarios
# (similar to RSpec configuration in spec/rails_helper.rb)

# Enable Warden test mode at the start of the test suite
BeforeAll do
  Warden.test_mode!
end

# CRITICAL: Ensure clean state BEFORE each scenario starts
# This is essential in CI with parallel execution where sessions can persist
Before do |scenario|
  # Log which scenario is starting (helpful for debugging CI failures)
  Rails.logger.info { "\n=== Starting scenario: #{scenario.name} ===" }

  # Reset Warden session state
  Warden.test_reset!

  # Reset Capybara sessions (plural - resets ALL sessions)
  Capybara.reset_sessions!
end

# More aggressive cleanup AFTER each scenario
# This runs AFTER the scenario completes, giving us access to the browser
After do |scenario|
  Rails.logger.info { "=== Cleaning up after scenario: #{scenario.name} ===" }

  # For Selenium drivers: quit the browser entirely
  # This ensures no state carries over to the next scenario
  begin
    if Capybara.current_session.driver.respond_to?(:quit)
      Capybara.current_session.driver.quit
      Rails.logger.debug { 'Browser quit after scenario' }
    end
  rescue StandardError => e
    Rails.logger.debug { "Browser quit skipped: #{e.message}" }
  end

  # Reset all sessions
  Capybara.reset_sessions!
  Warden.test_reset!
end

AfterAll do
  Warden.test_reset!

  # Final cleanup: quit all browser instances
  begin
    Capybara.current_session.driver.quit if Capybara.current_session.driver.respond_to?(:quit)
  rescue StandardError
    # Ignore - browser may already be closed
  end
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
