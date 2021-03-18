# frozen_string_literal: true

# Sets @current_user
Given('I have a confirmed account') do
  @current_user = FactoryBot.create(:user, current_sign_in_at: nil)
  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.current_sign_in_at).to be nil
end

# Sets @current_user
Given('I have an unconfirmed account') do
  @current_user = FactoryBot.create(:user, confirmed_at: nil, current_sign_in_at: nil)
  expect(@current_user.confirmed_at).to be nil
  expect(@current_user.current_sign_in_at).to be nil
end

# Sets @current_user
Given('I have a locked account') do
  @current_user = FactoryBot.create(:user, locked_at: Time.zone.now, current_sign_in_at: nil)
  expect(@current_user.locked_at).to be_present
  expect(@current_user.current_sign_in_at).to be nil
end

Given('I am a new user') do
  @new_user = FactoryBot.build(:user)
  expect(@new_user).to be_a(GogglesDb::User).and be_valid
end

# Uses @current_user
Given('I have an existing account with an email valid for {string} sign-in') do |provider_name|
  step('I have a confirmed account')
  OmniAuth.config.mock_auth[provider_name.downcase.to_sym] = valid_auth(provider_name.downcase, (GogglesDb::User.last.id + 1).to_s, @current_user)
end

Given('I don\'t have valid credentials for {string} sign-in') do |provider_name|
  OmniAuth.config.mock_auth[provider_name.downcase.to_sym] = :invalid_credentials
end

# Uses @current_user
Given('I have an existing account but I don\'t have credentials for {string} sign-in') do |provider_name|
  step('I have a confirmed account')
  step("I don't have valid credentials for '#{provider_name}' sign-in")
end

# Uses @new_user; sets a new @current_user
Given('I have valid {string} credentials but no local account') do |provider_name|
  step('I am a new user')
  @current_user = @new_user
  @auth_hash = valid_auth(provider_name.downcase, (GogglesDb::User.last.id + 1).to_s, @current_user)
  OmniAuth.config.mock_auth[provider_name.downcase.to_sym] = @auth_hash
  Rails.application.env_config['omniauth.auth'] = @auth_hash
end

# Creates @matching_swimmer
# Assumes @current_user is available and valid for reloading
Given('I have an available matching swimmer for my user') do
  @current_user.reload
  @matching_swimmer = FactoryBot.create(
    :swimmer,
    first_name: @current_user.first_name,
    last_name: @current_user.last_name,
    complete_name: @current_user.description,
    year_of_birth: @current_user.year_of_birth
  )
end
