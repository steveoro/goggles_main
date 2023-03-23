# frozen_string_literal: true

Given('there are more than {int} workshops matching my query {string}') do |min_count, query_string|
  expect(GogglesDb::UserWorkshop.for_name(query_string).count).to be > min_count
end

Given('there are no more than {int} workshops matching my query {string}') do |max_count, query_string|
  expect(GogglesDb::UserWorkshop.for_name(query_string).count).to be <= max_count
end

Given('there are no workshops matching my query {string}') do |query_string|
  expect(GogglesDb::UserWorkshop.for_name(query_string).count).to be_zero
end
# -----------------------------------------------------------------------------

# Sets @chosen_workshop
# Uses @associated_urs
Given('I have already selected a random workshop from any of my available results') do
  @chosen_workshop = @associated_urs.sample.user_workshop
  expect(@chosen_workshop).to be_a(GogglesDb::UserWorkshop).and be_valid
end
