# frozen_string_literal: true

# Uses:
# - @managed_team
# - @chosen_meeting
# Sets:
# - @chosen_mrr to a GogglesDb::MeetingRelayResult
# - @chosen_mevent the event of @chosen_mrr
Given('I select a random relay result from my chosen team') do
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
  @chosen_mrr = @chosen_meeting.meeting_relay_results
                               .includes(:meeting_event)
                               .where(team_id: @managed_team.id)
                               .sample
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  @chosen_mevent = @chosen_mrr.meeting_event
end
# -----------------------------------------------------------------------------
