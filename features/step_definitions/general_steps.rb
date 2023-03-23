# frozen_string_literal: true

When('I wait for {int} seconds') do |sleep_time_in_secs|
  sleep_time_in_secs.times do
    sleep(1) && wait_for_ajax
    putc('.')
  end
end

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

# Whenever the current URL requires Devise user authentication and it's not
# the actual Devise sign-in path, the current_path will remain set to the requested
# path so that Devise can redirect to the final destination after successful sign-in.
# Thus in these cases we just check the page contents since we cannot rely on the current_path.
Then('I get redirected to the sign-in page') do
  sleep(1) && wait_for_ajax
  find('#content .main-content #login-box', visible: true)
end

# Checks current_path vs. the specified string.
# Note that relative current_path should always start with a '/'.
Then('I am still at the {string} path') do |string_path|
  sleep(1) && wait_for_ajax
  # Wait for content to be rendered and then verify path:
  find_by_id('content', visible: true)
  expect(page).to have_current_path(string_path)
end

# Alias #1:
Then('I get redirected to {string}') do |string_path|
  step("I am still at the '#{string_path}' path")
end

# Alias #2:
Given('I am already at the {string} page') do |string_path|
  step("I am still at the '#{string_path}' path")
end

# Alias #3:
Given('I am at the {string} page') do |string_path|
  step("I am still at the '#{string_path}' path")
end
# -----------------------------------------------------------------------------

Then('a flash {string} message is present') do |i18n_key|
  # [Steve A.] Due to flash modals to disappear automatically after a delay,
  # we won't test visibility but just that the content has been actually rendered
  flash_content = find('.flash-body')
  expect(flash_content.text).to eq(I18n.t(i18n_key))
end
# -----------------------------------------------------------------------------

When('I click on {string}') do |string_css|
  find(string_css, visible: true).click
end

When('I click on {string} waiting {int} seconds') do |string_css, sleep_time_in_secs|
  link_node = find(string_css, visible: true)
  link_node.click
  sleep_time_in_secs.times do
    sleep(1) && wait_for_ajax
    putc('.')
  end
end

When('I click on {string} waiting for the {string} to be ready') do |string_css, section_css|
  step("I click on '#{string_css}'")
  find(section_css, visible: true)
end

# Similar to the above, but uses the label instead of the CSS selector:
When('I click on the {string} button') do |string_label|
  click_button(string_label)
end

Then('an error message from the edit form is present') do
  error_title = find('#error_explanation h5')
  expect(error_title.text).to be_present
end
# -----------------------------------------------------------------------------

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
# -----------------------------------------------------------------------------

Then('I see the link to go back to the dashboard') do
  find("a#back-to-parent[href='#{home_dashboard_path}']", visible: true)
end

# Generic step for data grids with pagination and filtering
Then('I see the index grid list with filtering and pagination controls') do
  find('section#data-grid form')
  find('section#data-grid #datagrid-top-row', visible: true)
  find('section#data-grid #filter-show-btn', visible: true)
  find('section#data-grid #pagination-top')
  find('section#data-grid table', visible: true)
  find('section#data-grid #pagination-bottom')
end

When('I make sure the filtering form for the datagrid is visible') do
  toggle_btn = find('#filter-show-btn button', visible: true)
  # Show the filtering form if collapsed:
  toggle_btn.click unless find('section#data-grid form').visible?
end

When('I submit the filters for the datagrid {string} waiting {int} secs tops for it to disappear') do |datagrid_dom_id, sleep_time_in_secs|
  visible = true
  find("section#data-grid form.datagrid-form#{datagrid_dom_id} .datagrid-actions input[type=\"submit\"]", visible: true).click

  while sleep_time_in_secs.positive? && visible
    putc('.')
    sleep(1) && wait_for_ajax
    sleep_time_in_secs -= 1
    visible = find("section#data-grid form.datagrid-form#{datagrid_dom_id}").visible?
    find("section#data-grid form.datagrid-form#{datagrid_dom_id} .datagrid-actions input[type=\"submit\"]", visible: true).click if visible
  end
end
# -----------------------------------------------------------------------------

Then('I check {string} as a selected checkbox') do |input_id|
  find("label[for='#{input_id}']").click
end

Then('I see that the {string} checkbox is unchecked') do |input_id|
  expect(find("input##{input_id}")).not_to be_checked
end

Then('I fill the {string} field with {string}') do |input_id, string_value|
  fill_in(input_id, with: string_value)
end

Then('I select {string} for the {string} select field') do |string_value, input_id|
  find("##{input_id}").set(string_value)
end
# -----------------------------------------------------------------------------
