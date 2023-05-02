# frozen_string_literal: true

Given('there are more than {int} teams matching my query {string}') do |min_count, query_string|
  expect(GogglesDb::Team.for_name(query_string).count).to be > min_count
end

Given('there are no more than {int} teams matching my query {string}') do |max_count, query_string|
  expect(GogglesDb::Team.for_name(query_string).count).to be <= max_count
end

Given('there are no teams matching my query {string}') do |query_string|
  expect(GogglesDb::Team.for_name(query_string).count).to be_zero
end

# Sets @chosen_team
Given('I have a previously chosen a random team') do
  @chosen_team = GogglesDb::Team.first(300).sample
  expect(@chosen_team).to be_a(GogglesDb::Team).and be_valid
end

# Designed for Meetings
# Sets @chosen_team
Given('I have a chosen a random team with existing MIRs') do
  # It's faster using 2 queries instead of 1:
  team_id = GogglesDb::MeetingIndividualResult.includes(:team).joins(:team)
                                              .distinct(:team_id).pluck(:team_id)
                                              .first(300).sample
  @chosen_team = GogglesDb::Team.find(team_id)
end

# Designed for UserWorkshops
# Sets @chosen_team
Given('I have a chosen a random team with existing user results') do
  expect(GogglesDb::UserResult.count).to be_positive
  # It's faster using 2 queries instead of 1:
  team_id = GogglesDb::UserResult.includes(user_workshop: [:team]).joins(user_workshop: [:team])
                                 .distinct('user_workshops.team_id').pluck(:team_id)
                                 .first(300).sample
  @chosen_team = GogglesDb::Team.find(team_id)
end

# Designed for Meetings
# Sets @chosen_team
# Uses @chosen_meeting
Given('I have a chosen a random team from the results of the current meeting') do
  team_id = @chosen_meeting.meeting_individual_results.distinct(:team_id).pluck(:team_id).sample
  @chosen_team = GogglesDb::Team.find(team_id)
end
