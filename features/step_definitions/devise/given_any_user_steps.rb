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

# Sets @current_user
Given('I have a deactivated account') do
  @current_user = FactoryBot.create(:user, active: false, current_sign_in_at: nil)
  expect(@current_user.active).to be false
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

# Prepares a ManagedAffiliation for each @last_season_ids found, setting also
# the current user and its associated swimmer using the first managed affiliation
# created or found.
#
# Sets:
# - @current_user
# - @matching_swimmer
# - @last_seasons_ids => list of valid Season IDs considered as "manageable"
Given('I have an associated swimmer on a confirmed team manager account') do
  # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:278)
  @last_seasons_ids = GogglesDb::LastSeasonId.all.map(&:id)
  # [Steve, 20230608] WAS:
  # @last_seasons_ids = [
  #   GogglesDb::Season.joins(meetings: :meeting_individual_results).last_season_by_type(GogglesDb::SeasonType.mas_fin).id,
  #   GogglesDb::UserWorkshop.for_season_type(GogglesDb::SeasonType.mas_fin).joins(:user_results, :season).by_season(:desc).first.season_id
  # ].uniq
  last_season_id = @last_seasons_ids.first

  team_affiliation = GogglesDb::TeamAffiliation.where(season_id: last_season_id).first ||
                     FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(last_season_id))
  managed_aff = GogglesDb::ManagedAffiliation.where(team_affiliation_id: team_affiliation.id).first ||
                FactoryBot.create(:managed_affiliation, team_affiliation:)
  expect(managed_aff.team).to be_valid
  expect(managed_aff.season).to be_valid

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
  expect(@current_user.confirmed_at).to be_present
  expect(@current_user.swimmer_id).to eq(@matching_swimmer.id)
  expect(@matching_swimmer.associated_user_id).to eq(@current_user.id)

  # For completeness, build any missing managed association for all possible remaining season IDs:
  @last_seasons_ids[1..].each do |season_id|
    next unless managed_aff.season.id != season_id

    additional_team_aff = GogglesDb::TeamAffiliation.where(season_id:).first ||
                          FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(season_id))
    GogglesDb::ManagedAffiliation.where(team_affiliation_id: additional_team_aff.id, user_id: @current_user.id).first ||
      FactoryBot.create(:managed_affiliation, team_affiliation: additional_team_aff, manager: @current_user)
  end
end
# -----------------------------------------------------------------------------

# Designed for Meetings
# Sets:
# - @current_user
# - @matching_swimmer
# - @associated_mirs => MIRS associated to the @matching_swimmer (these can be used to select a meeting)
Given('I have a confirmed account with associated swimmer and existing MIRs') do
  # It's faster using 2 queries instead of 1:
  swimmer_id = GogglesDb::MeetingIndividualResult.includes(swimmer: [:associated_user])
                                                 .joins(swimmer: [:associated_user])
                                                 .distinct(:swimmer_id).first(500)
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
  @associated_mirs = GogglesDb::MeetingIndividualResult.where(swimmer_id:)
  expect(@associated_mirs.count).to be_positive
end

# Designed for Meetings & Team Managers
# (Similar to the above, w/o setting an associated swimmer)
# Sets:
# - @current_user
# - @managed_team
# - @associated_mirs => MIRS associated to the @managed_team
# - @last_seasons_ids => list of valid Season IDs considered as "manageable"
Given('I have a confirmed team manager account managing some existing MIRs') do
  # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:278)
  @last_seasons_ids = [
    GogglesDb::Season.joins(meetings: :meeting_individual_results).last_season_by_type(GogglesDb::SeasonType.mas_fin).id
  ]
  last_season_id = @last_seasons_ids.first

  # Make sure we choose a team w/ results by selecting the meeting first & the team manager afterwards,
  # creating also anything that's beeen missing:
  meeting_with_results = GogglesDb::Meeting.includes(:meeting_individual_results).joins(:meeting_individual_results)
                                           .where(season_id: last_season_id)
                                           .by_date(:desc).first(25)
                                           .sample
  @managed_team = meeting_with_results.meeting_individual_results.sample.team
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  @associated_mirs = GogglesDb::MeetingIndividualResult.includes(meeting: :season).joins(meeting: :season)
                                                       .where(team_id: @managed_team.id, 'meetings.season_id': last_season_id)
  expect(@associated_mirs.count).to be_positive

  team_affiliation = GogglesDb::TeamAffiliation.where(team_id: @managed_team.id, season_id: last_season_id).first ||
                     FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(last_season_id))
  managed_aff = GogglesDb::ManagedAffiliation.where(team_affiliation_id: team_affiliation.id).first ||
                FactoryBot.create(:managed_affiliation, team_affiliation:)

  @current_user = managed_aff.manager
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!
  expect(@current_user.confirmed_at).to be_present
end

# == Less restrictive domain case for managing "any MRRs"
#
# Designed for Meetings & Team Managers (similar to the above, w/o setting an associated swimmer).
# Selects any team "with MRRs" from the latest available FIN season (with MRRs present in it).
# The current user will become a TeamManager for that team, in the season of the chosen Meeting.
#
# Sets:
# - @current_user
# - @managed_team
# - @associated_mrrs => MRRS associated to the @managed_team
# - @last_seasons_ids => list of valid Season IDs considered as "manageable"
Given('I have a confirmed team manager account managing some existing MRRs') do
  # Consider last season *including* results:
  # (NOTE: cfr. app/controllers/application_controller.rb:278)

  # == Less restrictive: "any MRRs"
  @last_seasons_ids = [
    GogglesDb::Season.joins(meetings: :meeting_relay_results)
                     .last_season_by_type(GogglesDb::SeasonType.mas_fin).id
  ]
  last_season_id = @last_seasons_ids.first

  # Make sure we choose a team w/ results by selecting the meeting first & the team manager afterwards,
  # creating also anything that's beeen missing:
  meeting_with_results = GogglesDb::Meeting.includes(:meeting_relay_results).joins(:meeting_relay_results)
                                           .where(season_id: last_season_id)
                                           .by_date(:desc).first(25)
                                           .sample
  @managed_team = meeting_with_results.meeting_relay_results.sample.team
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  @associated_mrrs = GogglesDb::MeetingRelayResult.includes(meeting: :season).joins(meeting: :season)
                                                  .where(team_id: @managed_team.id, 'meetings.season_id': last_season_id)
  expect(@associated_mrrs.count).to be_positive

  team_affiliation = GogglesDb::TeamAffiliation.where(team_id: @managed_team.id, season_id: last_season_id).first ||
                     FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(last_season_id))
  managed_aff = GogglesDb::ManagedAffiliation.where(team_affiliation_id: team_affiliation.id).first ||
                FactoryBot.create(:managed_affiliation, team_affiliation:)

  @current_user = managed_aff.manager
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!
  expect(@current_user.confirmed_at).to be_present
end

# == More complex domain case for managing "long MRRs" (4x100s/4x200s, relays w/ "sublaps")
#
# Designed for Meetings & Team Managers (similar to the above, w/o setting an associated swimmer).
# Selects any team from "long MRRs" from the latest available FIN season with long MRRs in it.
# The current user will become a TeamManager for that team, in the season of the chosen Meeting.
#
# Sets:
# - @current_user
# - @managed_team
# - @associated_mrrs => MRRS (only "long length") associated to the @managed_team
# - @last_seasons_ids => list of valid Season IDs considered as "manageable" (given the type of results searched for)
#
Given('I have a confirmed team manager account managing some existing MRRs with possible sublaps') do
  # Consider last season *including* results:
  # (NOTE: cfr. app/controllers/application_controller.rb:278)

  @last_seasons_ids = [
    GogglesDb::Season.includes(
      meetings: [meeting_relay_results: { meeting_event: :event_type }]
    ).joins(
      meetings: [meeting_relay_results: { meeting_event: :event_type }]
    ).where(
      'event_types.code': %w[S4X100SL S4X100MI S4X200SL M4X100SL M4X100MI M4X200SL]
    ).last_season_by_type(GogglesDb::SeasonType.mas_fin).id
  ]
  last_season_id = @last_seasons_ids.first

  # Make sure we choose a team w/ results by selecting the meeting first & the team manager afterwards,
  # creating also anything that's been missing:
  meeting_with_results = GogglesDb::Meeting.includes(meeting_relay_results: { meeting_event: :event_type })
                                           .joins(meeting_relay_results: { meeting_event: :event_type })
                                           .where(season_id: last_season_id, 'event_types.code': %w[S4X100SL S4X100MI S4X200SL M4X100SL M4X100MI M4X200SL])
                                           .by_date(:desc).first(25)
                                           .sample
  long_mrrs = GogglesDb::MeetingRelayResult.includes(:meeting, { meeting_event: :event_type })
                                           .joins(:meeting, { meeting_event: :event_type })
                                           .where(
                                             'meetings.id': meeting_with_results.id,
                                             'event_types.code': %w[S4X100SL S4X100MI S4X200SL M4X100SL M4X100MI M4X200SL]
                                           )
  @managed_team = long_mrrs.sample.team
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  @associated_mrrs = long_mrrs.where(team_id: @managed_team.id)
  expect(@associated_mrrs.count).to be_positive

  team_affiliation = GogglesDb::TeamAffiliation.where(team_id: @managed_team.id, season_id: last_season_id).first ||
                     FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(last_season_id))
  managed_aff = GogglesDb::ManagedAffiliation.where(team_affiliation_id: team_affiliation.id).first ||
                FactoryBot.create(:managed_affiliation, team_affiliation:)

  @current_user = managed_aff.manager
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!
  expect(@current_user.confirmed_at).to be_present
end
# -----------------------------------------------------------------------------

# Designed for UserWorkshops
# Sets:
# - @current_user
# - @matching_swimmer
# - @associated_urs => UserResults associated to the @matching_swimmer (these can be used to select a Workshop)
Given('I have a confirmed account with associated swimmer and existing user results') do
  expect(GogglesDb::UserResult.count).to be_positive
  # It's faster using 2 queries instead of 1:
  swimmer_id = GogglesDb::UserResult.includes(swimmer: [:associated_user])
                                    .joins(swimmer: [:associated_user])
                                    .distinct(:swimmer_id).pluck(:swimmer_id)
                                    .first(300).sample
  unless swimmer_id
    swimmer_id = GogglesDb::Swimmer.joins(:associated_user).first(20).sample.id
    FactoryBot.create_list(:user_result_with_laps, 3, swimmer_id:)
  end
  expect(swimmer_id).to be_positive
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
  @associated_urs = GogglesDb::UserResult.where(swimmer_id:)
  expect(@associated_urs.count).to be_positive
end

# Designed for UserWorkshops & Team Managers
# (Similar to the above, w/o setting an associated swimmer)
# Sets:
# - @current_user
# - @managed_team
# - @associated_urs => UserResults associated to the @managed_team
# - @last_seasons_ids => list of valid Season IDs considered as "manageable"
Given('I have a confirmed team manager account managing some existing URs') do
  # NOTE: this must also match app/controllers/application_controller.rb:278
  @last_seasons_ids = GogglesDb::LastSeasonId.all.map(&:id)
  # [Steve, 20230608] WAS:
  # @last_seasons_ids = [
  #   GogglesDb::UserWorkshop.for_season_type(GogglesDb::SeasonType.mas_fin).joins(:user_results, :season)
  #                          .by_season(:desc).first.season_id
  # ]
  last_season_id = @last_seasons_ids.sample
  last_season = GogglesDb::Season.find(last_season_id)

  # Make sure we choose a team w/ results by selecting the meeting first & the team manager afterwards,
  # creating also anything that's beeen missing:
  meeting_with_results = GogglesDb::UserWorkshop.includes(:user_results).joins(:user_results)
                                                .where(season_id: last_season_id)
                                                .by_date(:desc).first(25)
                                                .sample ||
                         FactoryBot.create(:workshop_with_results, season: last_season)

  @managed_team = meeting_with_results.team
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  @associated_urs = meeting_with_results.user_results
  expect(@associated_urs.count).to be_positive

  team_affiliation = GogglesDb::TeamAffiliation.where(team_id: @managed_team.id, season_id: last_season_id).first ||
                     FactoryBot.create(:team_affiliation, team: @managed_team, season: last_season)
  managed_aff = GogglesDb::ManagedAffiliation.where(team_affiliation_id: team_affiliation.id).first ||
                FactoryBot.create(:managed_affiliation, team_affiliation:)

  @current_user = managed_aff.manager
  @current_user.confirmed_at = Time.zone.now if @current_user.confirmed_at.blank?
  # This is needed when the user comes from the test seed and its password may be already encrypted:
  @current_user.password = 'Password123!' # force usage of test password for easier login
  @current_user.save!
  expect(@current_user.confirmed_at).to be_present
end
# -----------------------------------------------------------------------------

# Uses @matching_swimmer & sets @chosen_swimmer
Given('my associated swimmer is already the chosen swimmer for the meeting list') do
  @chosen_swimmer = @matching_swimmer
end
