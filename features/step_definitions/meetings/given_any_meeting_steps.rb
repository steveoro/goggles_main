# frozen_string_literal: true

Given('there are more than {int} meetings matching my query {string}') do |min_count, query_string|
  expect(GogglesDb::Meeting.for_name(query_string).count).to be > min_count
end

Given('there are no more than {int} meetings matching my query {string}') do |max_count, query_string|
  expect(GogglesDb::Meeting.for_name(query_string).count).to be <= max_count
end

Given('there are no meetings matching my query {string}') do |query_string|
  expect(GogglesDb::Meeting.for_name(query_string).count).to be_zero
end
# -----------------------------------------------------------------------------

# Sets @chosen_meeting
Given('I have already selected a random meeting with available results') do
  @chosen_meeting = GogglesDb::Meeting.includes(:meeting_individual_results)
                                      .joins(:meeting_individual_results)
                                      .last(50).sample
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
end

# Uses @associated_mirs, @chosen_mevent
# Sets @chosen_meeting, @associated_team_id
Given('I have already selected a random meeting and an event from any of my available results') do
  chosen_mir = @associated_mirs.includes(:meeting_event).sample
  @chosen_meeting = chosen_mir.meeting
  @associated_team_id = chosen_mir.team_id
  @chosen_mevent = chosen_mir.meeting_event
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
  expect(@chosen_mevent).to be_a(GogglesDb::MeetingEvent).and be_valid
end

# Uses @associated_mrrs
# Sets @chosen_meeting, @chosen_mevent, @associated_team_id
Given('I have already selected a random meeting and an event from any of my available relay results') do
  chosen_mrr = @associated_mrrs.includes(:meeting_event).sample
  @chosen_meeting = chosen_mrr.meeting
  @associated_team_id = chosen_mrr.team_id
  @chosen_mevent = chosen_mrr.meeting_event
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
  expect(@chosen_mevent).to be_a(GogglesDb::MeetingEvent).and be_valid
end

# Uses @associated_mrrs
# Sets @chosen_meeting, @chosen_mevent, @associated_team_id, @chosen_mrr
#
# Similar to the previous one, but sets also @chosen_mrr
Given('I have already selected a random meeting and a relay result from any of my available managed teams') do
  sample_mrr = @associated_mrrs.includes(:meeting_event, meeting_relay_swimmers: :relay_laps).sample
  @chosen_mrr = GogglesDb::MeetingRelayResult.includes(:meeting_event, meeting_relay_swimmers: :relay_laps).find(sample_mrr.id)
  @chosen_meeting = @chosen_mrr.meeting
  @associated_team_id = @chosen_mrr.team_id
  @chosen_mevent = @chosen_mrr.meeting_event
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
  expect(@chosen_mevent).to be_a(GogglesDb::MeetingEvent).and be_valid
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
end
