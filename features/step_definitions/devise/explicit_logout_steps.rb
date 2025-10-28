# frozen_string_literal: true

# Explicitly ensures no session exists at all
# Use this at the VERY START of scenarios testing anonymous access
# This is nuclear option for CI environments where session cleanup between
# scenarios may not work reliably with certain Capybara drivers
Given('no user session exists') do
  # Step 1: Clear any instance variables that might hold user references FIRST
  # This prevents any subsequent operations from accessing them
  @current_user = nil
  @user_credentials = nil
  @matching_swimmer = nil
  @chosen_swimmer = nil
  @associated_mirs = nil
  @associated_mrrs = nil
  @associated_urs = nil

  # Step 2: For Selenium drivers, quit the browser entirely and start fresh
  # This is MORE aggressive than reset_session! - it actually closes the browser
  begin
    if Capybara.current_session.driver.respond_to?(:quit)
      Capybara.current_session.driver.quit
      Rails.logger.info { '[CLEANUP] Browser quit - will restart fresh' }
    end
  rescue StandardError => e
    Rails.logger.debug { "[CLEANUP] Browser quit skipped: #{e.message}" }
  end

  # Step 3: Reset all session mechanisms
  # This will start a fresh browser instance when next needed
  Capybara.reset_sessions! # NOTE: plural - resets ALL sessions
  Warden.test_reset!

  Rails.logger.info { '[CLEANUP] Sessions reset - clean slate ready' }

  # Step 4: Give the system time to fully clean up
  sleep(0.5)

  # Step 5: Verify by visiting a simple public page
  # Use /about which requires no authentication and minimal processing
  visit('/about')
  wait_for_ajax && sleep(0.5)

  # Now verify no sign-out link is present
  has_logout_link = page.has_css?('#link-logout', visible: :all)

  if has_logout_link
    # Log detailed debugging info to help diagnose the issue
    Rails.logger.error { '[CLEANUP FAILED] Sign-out link still present after cleanup!' }
    Rails.logger.error { "[CLEANUP FAILED] Current URL: #{page.current_url}" }
    Rails.logger.error { "[CLEANUP FAILED] Driver: #{Capybara.current_driver}" }

    # Fail with clear message
    raise RSpec::Expectations::ExpectationNotMetError,
          "Expected no user to be signed in after cleanup, but found sign-out link in page. Driver: #{Capybara.current_driver}"
  end

  Rails.logger.info { '[CLEANUP] Verified: no user signed in' }
end
