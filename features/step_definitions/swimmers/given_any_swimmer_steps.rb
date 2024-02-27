# frozen_string_literal: true

Given('there are more than {int} swimmers matching my query {string}') do |min_count, query_string|
  expect(GogglesDb::Swimmer.for_name(query_string).count).to be > min_count
end

Given('there are no more than {int} swimmers matching my query {string}') do |max_count, query_string|
  expect(GogglesDb::Swimmer.for_name(query_string).count).to be <= max_count
end

Given('there are no swimmers matching my query {string}') do |query_string|
  expect(GogglesDb::Swimmer.for_name(query_string).count).to be_zero
end

# Sets @chosen_swimmer
Given('I have a previously chosen a random swimmer') do
  @chosen_swimmer = GogglesDb::Swimmer.last(250).sample
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
end

# Designed for Meetings
# Sets @chosen_swimmer
Given('I have a chosen a random swimmer with existing MIRs') do
  # It's faster using 2 queries instead of 1:
  swimmer_id = GogglesDb::MeetingIndividualResult.includes(:swimmer).joins(:swimmer)
                                                 .distinct(:swimmer_id).pluck(:swimmer_id)
                                                 .last(250).sample
  @chosen_swimmer = GogglesDb::Swimmer.find(swimmer_id)
end

# Designed for UserWorkshops
# Sets @chosen_swimmer, @associated_urs
Given('I have a chosen a random swimmer with existing user results') do
  expect(GogglesDb::UserResult.count).to be_positive
  # It's faster using 2 queries instead of 1:
  swimmer_id = GogglesDb::UserResult.includes(:swimmer).joins(:swimmer)
                                    .distinct(:swimmer_id).pluck(:swimmer_id)
                                    .last(250).sample
  @chosen_swimmer = GogglesDb::Swimmer.find(swimmer_id)
  @associated_urs = GogglesDb::UserResult.where(swimmer_id:)
  expect(@associated_urs.count).to be_positive
end

# Designed for History
# Uses @chosen_swimmer, sets @chosen_event_type
Given('I have a chosen a random event type for the already chosen swimmer') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  # It's faster using 2 queries instead of 1:
  event_type_id = GogglesDb::MeetingIndividualResult.where(swimmer_id: @chosen_swimmer.id)
                                                    .includes(:event_type).joins(:event_type)
                                                    .distinct('event_types.id').pluck('event_types.id')
                                                    .first(100).sample
  @chosen_event_type = GogglesDb::EventType.find(event_type_id)
end
