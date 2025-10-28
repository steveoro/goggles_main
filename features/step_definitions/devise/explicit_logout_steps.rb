# frozen_string_literal: true

# Explicitly ensures no session exists at all
# Use this at the VERY START of scenarios testing anonymous access
# This is nuclear option for CI environments where session cleanup between
# scenarios may not work reliably with certain Capybara drivers
Given('no user session exists') do
  # Step 1: Reset all session mechanisms
  Warden.test_reset!
  Capybara.reset_session!

  # Step 2: Clear any instance variables that might hold user references
  @current_user = nil
  @user_credentials = nil

  # Step 3: For Selenium drivers, explicitly delete all browser cookies
  begin
    page.driver.browser.manage.delete_all_cookies if page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:manage)
  rescue StandardError => e
    Rails.logger.debug { "Cookie deletion skipped: #{e.message}" }
  end

  # Step 4: Visit root page to ensure clean slate
  # This forces the browser to make a request with the cleared session
  visit('/')

  # Step 5: Wait for page to fully render
  wait_for_ajax && sleep(1)

  # Step 6: Verify no user is signed in by checking page content
  # The sign-out link (#link-logout) should NOT be present
  expect(page).to have_no_css('#link-logout', visible: :all),
                  'Expected no user to be signed in, but found sign-out link in page'
end
