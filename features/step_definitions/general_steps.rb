# frozen_string_literal: true

When('I browse to {string}') do |string_path|
  visit(string_path)
end

Then('I get redirected to {string}') do |string_path|
  # Wait for content to be rendered and then verify path:
  find('#content', visible: true)
  expect(current_url).to include(string_path)
end
