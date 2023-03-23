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
# Uses @associated_mirs
Given('I have already selected a random meeting from any of my available results') do
  @chosen_meeting = @associated_mirs.sample.meeting
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting).and be_valid
end
