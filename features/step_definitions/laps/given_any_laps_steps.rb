# frozen_string_literal: true

# Uses:
# - @managed_team
# - @chosen_meeting
# Sets:
# - @chosen_mir to a GogglesDb::MeetingIndividualResult
Given('I select a random individual result from my chosen team') do
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
  @chosen_mir = @chosen_meeting.meeting_individual_results
                               .where(team_id: @managed_team.id)
                               .sample
  expect(@chosen_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
end

# Uses:
# - @managed_team
# - @chosen_workshop
# Sets:
# - @chosen_mir to a GogglesDb::UserResult
Given('I select a random user result from my chosen team') do
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  expect(@chosen_workshop).to be_a(GogglesDb::UserWorkshop).and be_valid
  @chosen_mir = @chosen_workshop.user_results.sample

  expect(@chosen_mir).to be_a(GogglesDb::UserResult).and be_valid
end
# -----------------------------------------------------------------------------
