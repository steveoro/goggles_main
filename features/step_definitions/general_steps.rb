# frozen_string_literal: true

Then('I debug') do
  # rubocop:disable Lint/Debugger
  save_and_open_page
  save_and_open_screenshot
  binding.pry
  # rubocop:enable Lint/Debugger
end

When('I browse to {string}') do |string_path|
  visit(string_path)
end

Then('I am still at the {string} path') do |string_path|
  # Wait for content to be rendered and then verify path:
  find('#content', visible: true)
  # Extract just the path part:
  current_local_path = current_url.split(":#{Capybara.current_session.server.port}").last
  expect(current_local_path).to eq(string_path)
end

# Alias:
Then('I get redirected to {string}') do |string_path|
  step("I am still at the '#{string_path}' path")
end

Then('a flash {string} message is present') do |i18n_key|
  # [Steve A.] Due to flash modals to disappear automatically after a delay,
  # we won't test visibility but just that the content has been actually rendered
  flash_content = find('.flash-body')
  expect(flash_content.text).to eq(I18n.t(i18n_key))
end

When('I click on {string}') do |string_css|
  find(string_css).click
end

Then('an error message from the edit form is present') do
  error_title = find('#error_explanation h5')
  expect(error_title.text).to be_present
end

# Click on OK/Yes
When('I click on {string} accepting the confirmation request') do |string_css|
  accept_confirm do
    find(string_css).click
  end
end

# Click on Cancel/No
When('I click on {string} rejecting the confirmation request') do |string_css|
  dismiss_confirm do
    find(string_css).click
  end
end
