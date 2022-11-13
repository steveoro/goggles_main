# frozen_string_literal: true

# Also reloads @current_user if defined
Given('I am not signed in') do
  current_driver = Capybara.current_driver
  begin
    Capybara.current_driver = :rack_test
    page.driver.submit :delete, destroy_user_session_path, {}
  ensure
    Capybara.current_driver = current_driver
  end
  @current_user&.reload
end

# Requires a @current_user
When('I fill the log-in form as the confirmed user') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  wait_for_ajax && sleep(2)
  find('#login-box', visible: true) # wait for rendering ("visit" doesn't)
  fill_in('user_email', with: @current_user.email)
  fill_in('user_password', with: @current_user.password)
  btn = find('#login-btn', visible: true)
  page.scroll_to(btn) # force the button into the center of the viewport
  wait_for_ajax && sleep(0.5)
  btn.click
end

# Requires a @current_user
Given('the user row is signed-in') do
  @current_user.reload
  expect(@current_user.current_sign_in_at).to be_present
end

# Requires a @current_user (uses 'current' as synonim of 'new' & 'my')
When(/I fill the log-in form as (the current|the new|my) user/) do |_user_type|
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  wait_for_ajax && sleep(2)
  find('#login-box', visible: true) # wait for rendering ("visit" doesn't)
  fill_in('user_email', with: @current_user.email)
  fill_in('user_password', with: 'Password123!')
  btn = find('#login-btn', visible: true)
  page.scroll_to(btn) # force the button into the center of the viewport
  wait_for_ajax && sleep(0.5)
  btn.click
end

Then('an unsuccessful login flash message is present') do
  # [Steve A.] Due to flash modals to disappear automatically after a delay,
  # we won't test visibility but just the content:
  flash_content = find('.flash-body')
  authentication_key = I18n.t('activerecord.attributes.goggles_db/user.email')
  msg_content = I18n.t('devise.failure.invalid', authentication_keys: authentication_key)
  expect(flash_content.text).to eq(msg_content)
end

Then('a successful Omniauth flash message for {string} is present') do |provider_name|
  flash_content = find('.flash-body')
  msg_content = I18n.t('devise.omniauth_callbacks.success', kind: provider_name)
  expect(flash_content.text).to eq(msg_content)
end

# Prepares & sets a new @current_user
When('I fill the registration form as a new user') do
  @current_user = FactoryBot.build(:user)
  wait_for_ajax && sleep(2)
  find('#signup-box', visible: true) # wait for rendering ("visit" doesn't)
  fill_in('user_email', with: @current_user.email)
  fill_in('user_name', with: @current_user.name)
  fill_in('user_password', with: 'Password123!')
  fill_in('user_password_confirmation', with: 'Password123!')
  fill_in('user_first_name', with: @current_user.first_name)
  fill_in('user_last_name', with: @current_user.last_name)
  fill_in('user_year_of_birth', with: @current_user.year_of_birth)
  btn = find('#signup-btn', visible: true)
  page.scroll_to(btn) # force the button into the center of the viewport
  wait_for_ajax && sleep(0.5)
  btn.click
end

# Assumes @current_user has been previously built or set
Then('the user account is persisted') do
  @current_user = GogglesDb::User.find_by(email: @current_user.email)
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
end

# Assumes @current_user is loaded and valid
Then('the account is not yet confirmed') do
  expect(@current_user.confirmed_at).to be nil
end

# Assumes @current_user is loaded and valid
Then('the account is confirmed') do
  expect(@current_user.confirmed_at).to be_present
end

# Requires @auth_hash & sets @current_user
Then('I can see that my user is the one from the OAuth response') do
  expect(find('#user_email').value).to eq(@auth_hash.info.email)
  expect(find('#user_name').value).to eq(@auth_hash.info.name)
  expect(find('#user_first_name').value).to eq(@auth_hash.info.first_name)
  expect(find('#user_last_name').value).to eq(@auth_hash.info.last_name)
  @current_user = GogglesDb::User.find_by(email: @auth_hash.info.email)
end

# Prepares & sets a new @current_user
When('I fill the registration form as an existing user') do
  @current_user = GogglesDb::User.first(50).sample
  wait_for_ajax && sleep(2)
  find('#signup-box', visible: true) # wait for rendering ("visit" doesn't)
  fill_in('user_email', with: @current_user.email)
  fill_in('user_name', with: @current_user.name)
  fill_in('user_password', with: 'Password123!')
  fill_in('user_password_confirmation', with: 'Password123!')
  fill_in('user_first_name', with: @current_user.first_name)
  fill_in('user_last_name', with: @current_user.last_name)
  fill_in('user_year_of_birth', with: @current_user.year_of_birth)
  btn = find('#signup-btn', visible: true)
  page.scroll_to(btn) # force the button into the center of the viewport
  wait_for_ajax && sleep(0.5)
  btn.click
end

# Uses @current_user
Given('I sign-in with my existing account') do
  visit('/users/sign_in')
  step('I fill the log-in form as the confirmed user')
  step('the user row is signed-in')
end

Given('I am already signed-in and at the root page') do
  step('I have a confirmed account')
  visit('/users/sign_in')
  step('I fill the log-in form as the confirmed user')
  step('the user row is signed-in')
end

Given('I have an associated swimmer and have already signed-in') do
  step('I have an associated swimmer on a confirmed account')
  visit('/users/sign_in')
  step('I fill the log-in form as the confirmed user')
  step('the user row is signed-in')
end

Given('I have an associated swimmer on team manager account and have already signed-in') do
  step('I have an associated swimmer on a confirmed team manager account')
  visit('/users/sign_in')
  step('I fill the log-in form as the confirmed user')
  step('the user row is signed-in')
end

# Assumes @current_user is still loaded and valid
Then('the account is deleted') do
  expect(GogglesDb::User.exists?(id: @current_user.id)).to be false
end

# Assumes @current_user is still loaded and valid
Then('the account is still existing') do
  expect(GogglesDb::User.exists?(id: @current_user.id)).to be true
end
