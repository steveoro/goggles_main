# frozen_string_literal: true

Then('I am at the show page for the details of the team') do
  # We don't care which detail row is:
  expect(current_path).to include(team_show_path(-1).gsub('-1', ''))
end

Then('I am at the team swimmers page index for team ID {int}') do |team_id|
  expect(current_path).to include(team_current_swimmers_path(team_id))
end

Then('the list of swimmers is not displayed') do
  expect(page).not_to have_css('#swimmers-list table')
end

Then('I see the list of swimmers for team ID {int}') do |_team_id|
  expect(find('#swimmers-list table thead tr', visible: true)).to be_present
  expect(find('#swimmers-list table tbody tr', visible: true)).to be_present
  # (Currently don't care about how many rows are shown)
end
