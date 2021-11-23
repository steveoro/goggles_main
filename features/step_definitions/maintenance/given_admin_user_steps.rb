# frozen_string_literal: true

# Sets @current_user
Given('I have a confirmed account with Admin grants') do
  @current_user = FactoryBot.create(:user, current_sign_in_at: nil)
  FactoryBot.create(:admin_grant, user: @current_user, entity: nil)
  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.current_sign_in_at).to be nil
  expect(GogglesDb::GrantChecker.admin?(@current_user)).to be true
end

Given('I have Admin grants and have already signed-in and at the root page') do
  step('I have a confirmed account with Admin grants')
  visit('/users/sign_in')
  step('I fill the log-in form as the confirmed user')
  step('the user row is signed-in')
end
