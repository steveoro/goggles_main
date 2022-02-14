# frozen_string_literal: true

Then('I am at the show page for the details of the swimming pool') do
  # We don't care which detail row is:
  expect(current_path).to include(swimming_pool_show_path(-1).gsub('-1', ''))
end
