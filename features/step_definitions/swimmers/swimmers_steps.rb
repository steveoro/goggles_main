# frozen_string_literal: true

Then('I am at the show page for the details of the swimmer') do
  # We don't care which detail row is:
  expect(current_path).to include(swimmer_show_path(-1).gsub('-1', ''))
end
