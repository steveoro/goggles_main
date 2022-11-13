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

# Sets @current_user with Admin grants (any entity)
Given('I have a confirmed account with admin grants') do
  @current_user = FactoryBot.create(:user, current_sign_in_at: nil)
  FactoryBot.create(:admin_grant, user: @current_user, entity: nil)
  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.current_sign_in_at).to be nil
  expect(GogglesDb::GrantChecker.admin?(@current_user)).to be true
end

# Sets @current_user to an unsaved but valid user instance
Given('I am a new user') do
  @current_user = FactoryBot.build(:user)
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
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

# Uses @current_user
Given('I have valid {string} credentials but no local account') do |provider_name|
  step('I am a new user')
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

# Sets both @current_user & @matching_swimmer
Given('I have an associated swimmer on a confirmed account') do
  step('I have a confirmed account')
  step('I have an available matching swimmer for my user')
  @current_user.associate_to_swimmer!(@matching_swimmer)
  @matching_swimmer.reload

  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.current_sign_in_at).to be nil
  expect(@current_user.swimmer_id).to eq(@matching_swimmer.id)
  expect(@matching_swimmer.associated_user_id).to eq(@current_user.id)
end

# Sets:
# - @current_user
# - @matching_swimmer
# - @last_seasons_ids => list of valid Season IDs considered as "manageable"
Given('I have an associated swimmer on a confirmed team manager account') do
  # WIP/NOTE: *substitute* the following after we'll be done with old data-import testing,
  #           following what's written at app/controllers/application_controller.rb:44
  @last_seasons_ids = [182]

  managed_aff = FactoryBot.create(
    :managed_affiliation,
    team_affiliation: FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(@last_seasons_ids.sample))
  )
  @current_user = managed_aff.manager
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!
  if @current_user.swimmer.present?
    @matching_swimmer = @current_user.swimmer
  else
    @matching_swimmer = FactoryBot.create(
      :swimmer,
      first_name: @current_user.first_name,
      last_name: @current_user.last_name,
      complete_name: @current_user.description,
      year_of_birth: @current_user.year_of_birth
    )
    @current_user.associate_to_swimmer!(@matching_swimmer)
    @matching_swimmer.reload
  end

  expect(managed_aff.team).to be_valid
  expect(managed_aff.season).to be_valid
  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.swimmer_id).to eq(@matching_swimmer.id)
  expect(@matching_swimmer.associated_user_id).to eq(@current_user.id)
end

# Designed for Meetings
# Sets both @current_user & @matching_swimmer
Given('I have a confirmed account with associated swimmer and existing MIRs') do
  # It's faster using 2 queries instead of 1:
  swimmer_id = GogglesDb::MeetingIndividualResult.includes(swimmer: [:associated_user])
                                                 .joins(swimmer: [:associated_user])
                                                 .distinct(:swimmer_id).first(300)
                                                 .pluck(:swimmer_id)
                                                 .sample
  @matching_swimmer = GogglesDb::Swimmer.find(swimmer_id)
  expect(@matching_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  expect(@matching_swimmer.associated_user).to be_a(GogglesDb::User).and be_valid

  @current_user = @matching_swimmer.associated_user
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!

  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.swimmer_id).to eq(@matching_swimmer.id)
end

# Designed for UserWorkshops
# Sets both @current_user & @matching_swimmer
Given('I have a confirmed account with associated swimmer and existing user results') do
  expect(GogglesDb::UserResult.count).to be_positive
  # It's faster using 2 queries instead of 1:
  swimmer_id = GogglesDb::UserResult.includes(swimmer: [:associated_user])
                                    .joins(swimmer: [:associated_user])
                                    .distinct(:swimmer_id).pluck(:swimmer_id)
                                    .first(300).sample
  @matching_swimmer = GogglesDb::Swimmer.find(swimmer_id)
  expect(@matching_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  expect(@matching_swimmer.associated_user).to be_a(GogglesDb::User).and be_valid

  @current_user = @matching_swimmer.associated_user
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!

  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.swimmer_id).to eq(@matching_swimmer.id)
end

# Uses @matching_swimmer & sets @chosen_swimmer
Given('my associated swimmer is already the chosen swimmer for the meeting list') do
  @chosen_swimmer = @matching_swimmer
end
