# frozen_string_literal: true

Then('I am at the show page for the details of the team') do
  # We don't care which detail row is:
  expect(current_path).to include(team_show_path(-1).gsub('-1', ''))
end
