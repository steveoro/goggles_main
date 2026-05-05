# frozen_string_literal: true

# Uses:
# - @managed_team
# - @chosen_meeting
# Sets:
# - @chosen_mir to a GogglesDb::MeetingIndividualResult
# - @chosen_mevent the event of @chosen_mir
Given('I select a random individual result from my chosen team') do
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
  candidate_mirs = @chosen_meeting.meeting_individual_results
                                  .includes(:meeting_event, :laps)
                                  .where(team_id: @managed_team.id)
                                  .select do |mir|
    event_len = mir.event_type.length_in_meters
    last_lap = mir.laps.by_distance.last
    event_len > 25 && last_lap.present? && (last_lap.length_in_meters + 25 < event_len)
  end
  with_existing_laps = @chosen_meeting.meeting_individual_results
                                 .includes(:meeting_event, :laps)
                                 .where(team_id: @managed_team.id)
                                 .select { |mir| mir.laps.by_distance.present? }
  @chosen_mir = candidate_mirs.sample || with_existing_laps.sample || @chosen_meeting.meeting_individual_results
                                                                          .includes(:meeting_event)
                                                                          .where(team_id: @managed_team.id)
                                                                          .sample
  expect(@chosen_mir).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
  if @chosen_mir.laps.blank?
    FactoryBot.create(
      :lap,
      meeting_individual_result: @chosen_mir,
      meeting_program: @chosen_mir.meeting_program,
      swimmer: @chosen_mir.swimmer,
      team: @chosen_mir.team,
      length_in_meters: [50, @chosen_mir.event_type.length_in_meters].min
    )
    @chosen_mir.reload
  end
  @chosen_mevent = @chosen_mir.meeting_event
end

# Uses:
# - @managed_team
# - @chosen_workshop
# Sets:
# - @chosen_mir to a GogglesDb::UserResult
Given('I select a random user result from my chosen team') do
  expect(@managed_team).to be_a(GogglesDb::Team).and be_valid
  expect(@chosen_workshop).to be_a(GogglesDb::UserWorkshop).and be_valid
  candidate_urs = @chosen_workshop.user_results
                                  .includes(:user_laps)
                                  .select do |ur|
    event_len = ur.event_type.length_in_meters
    last_lap = ur.laps.by_distance.last
    event_len > 25 && last_lap.present? && (last_lap.length_in_meters + 25 < event_len)
  end
  with_existing_laps = @chosen_workshop.user_results.includes(:user_laps).select { |ur| ur.laps.by_distance.present? }
  @chosen_mir = candidate_urs.sample || with_existing_laps.sample || @chosen_workshop.user_results.sample

  expect(@chosen_mir).to be_a(GogglesDb::UserResult).and be_valid
end
# -----------------------------------------------------------------------------
