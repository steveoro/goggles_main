# frozen_string_literal: true

Then('I can see the issues FAQ breadcrumb title') do
  breadcrumb_title = find('section#issues-faq-title h4')
  back_to_parent = breadcrumb_title.find('a#back-to-parent')
  expect(back_to_parent[:href]).to include(root_path)
end

Then('I see the nav tab with the link to my issues grid') do
  nav_link = find('section#faq-index-navs ul.nav.nav-tabs li.nav-item a.nav-link', visible: true)
  expect(nav_link[:href]).to include(issues_my_reports_path)
end

Then('I see the expandable section for issues {string}') do |issue_type|
  find("#accordion .card .card-header#title-#{issue_type} h5", visible: true) # section header
  find("#accordion .card .collapse#body-#{issue_type}") # section_body
end

Then('I click to expand the issues section {string}') do |issue_type|
  find("#accordion .card .card-header#title-#{issue_type} h5", visible: true).click
  wait_for_ajax && sleep(0.5)
end
# -----------------------------------------------------------------------------

Then('I can see the My issues breadcrumb title') do
  breadcrumb_title = find('section#myreports-title h4')
  back_to_parent = breadcrumb_title.find('a#back-to-parent')
  expect(back_to_parent[:href]).to include(root_path)
end

Then('I see the nav tab with the link to the issues FAQ') do
  nav_link = find('section#tab-my-reports ul.nav.nav-tabs li.nav-item a.nav-link', visible: true)
  expect(nav_link[:href]).to include(issues_faq_index_path)
end

Then('I can see the empty grid of my issues') do
  grid_node = find('section#issues-grid .container', visible: true)
  expect(grid_node.text).to include(I18n.t('datagrid.no_results'))
end
# -----------------------------------------------------------------------------

Then('I can\'t see any of the {string} \({string}) buttons on the results of the page') do |_issue_name, issue_type|
  expect(page).to have_no_css("a.btn.issue-#{issue_type}-btn")
  # Alternatively, more explicit:
  #
  # find('a.btn', visible: true) # Make sure the page has rendered buttons
  # all_btn_styles = find_all('a.btn').map { |node| node[:class] }.uniq
  # expect(all_btn_styles.none? { |style| style.include?("issue-#{issue_type}-btn") }).to be true
end

Then('I can see the {string} \({string}) buttons on the results of the page') do |_issue_name, issue_type|
  step("I wait until the slow-rendered page portion 'a.btn.issue-#{issue_type}-btn' is visible")

  10.times do
    wait_for_ajax
    if page.has_css?("a.btn.issue-#{issue_type}-btn")
      sleep(0.5)
      putc '.'
      break
    else
      putc 'W'
    end
  end
  expect(page).to have_css("a.btn.issue-#{issue_type}-btn")
end

Then('I click a random {string} button on the page') do |issue_type|
  step("I wait until the slow-rendered page portion 'a.btn.issue-#{issue_type}-btn' is visible")
  chosen_btn = find_all("a.btn.issue-#{issue_type}-btn").sample
  expect(chosen_btn).to be_visible
  # NOTE
  # We'll send the click event using script with its unique DOM ID
  # because the web driver’s click() method is asynchronous and sometimes
  # Capybara starts the code execution before JS finishes initializing its listeners.
  # For an article about it, see:
  # https://medium.com/@alieckaja/capybara-inconsistent-click-behavior-and-flickering-tests-f50b5fae8ab2
  dom_id = chosen_btn[:id]
  execute_script("document.querySelector('##{dom_id}').click()")
  wait_for_ajax
  sleep(0.5)
  # Make sure the form is there:
  find("form#frm-#{issue_type}", visible: true)
end
# -----------------------------------------------------------------------------

Then('I am at the new issue {string} page') do |issue_type|
  # We don't care about the parameters here:
  expect(page.current_path.to_s.split('?').first).to include("/issues/new_#{issue_type}")
end
# -----------------------------------------------------------------------------

Then('I see the issue form {string}') do |issue_type|
  expect(page).to have_css("form##{issue_type}")
end

Then('I choose to manage season at index {int} in form type0') do |season_index|
  find("label[for='season_#{season_index}']").click
end

Then('I fill-in the results URL for the issue form with a random URL') do
  find('input#results_url').set(FFaker::Internet.http_url)
end

Then('I fill the result timing with random values') do
  fill_in('minutes', with: 1)
  fill_in('seconds', with: (20..35).to_a.sample)
  fill_in('hundredths', with: (rand * 99).to_i)
end

Then('I fill the result timing with a random correction') do
  fill_in('seconds', with: (rand * 59).to_i)
  fill_in('hundredths', with: (rand * 99).to_i)
end
# -----------------------------------------------------------------------------

Then('the issue {string} form {string} text is visible') do |issue_type, i18n_subkey|
  expect(page.find("form#frm-#{issue_type}").text).to include(I18n.t("issues.#{issue_type}.form.#{i18n_subkey}"))
end

Then('the issue {string} form {string} text is not visible') do |issue_type, i18n_subkey|
  expect(page.find("form#frm-#{issue_type}").text).not_to include(I18n.t("issues.#{issue_type}.form.#{i18n_subkey}"))
end
# -----------------------------------------------------------------------------

Then('the active nav tab is {string}') do |issue_type|
  find("ul li.nav-item##{issue_type}-nav-item .nav-link.active", visible: true)
end

Then('I select {string} as the active nav tab') do |issue_type|
  find("li.nav-item##{issue_type}-nav-item a.nav-link", visible: true).click
end
# -----------------------------------------------------------------------------

# USES (if present):
# - @select2_input_text => manual input for the select2 search dropdown, only if set
#   (see features/step_definitions/chrono/new_recording_setup_steps.rb:51)
# ASSUMES/SETS:
# - @latest_issue = GogglesDb::Issue.last
When('I see my newly created issue') do
  sleep(1)
  wait_for_ajax
  expect(GogglesDb::Issue.count).to be_positive
  @latest_issue = GogglesDb::Issue.last
  # In case we come from a select2 drop-down input box, the label should be in the request text too:
  expect(@latest_issue.req.to_s).to include(@select2_input_text) if @select2_input_text.present?

  # If there's a link to a last page, go to the last page:
  if page.has_css?('li.page-item span.last a.page-link')
    find('li.page-item span.last a.page-link').click
    sleep(0.5)
    wait_for_ajax
  end
  issue_grid = find('section#issues-grid table tbody', visible: true)
  last_row = issue_grid.find_all('tr', visible: true).last
  expect(issue_grid.text).to include(@latest_issue.req.to_s)
  expect(last_row.text).to include(@latest_issue.req.to_s)
end

# USES:
# - @current_user
When('I see the grid with the issues created by me') do
  first_page_issues = GogglesDb::Issue.for_user(@current_user).first(8)
  expect(first_page_issues.count).to be_positive

  issue_grid = find('section#issues-grid table tbody', visible: true)
  expect(issue_grid.find_all('tr', visible: true).count).to eq(first_page_issues.count)
end

# USES:
# - @current_user
# SETS:
# - @chosen_issue_row_id from any Issue of the current user from the first page of the grid
When('I choose an issue row to be deleted, accepting the confirmation request') do
  @chosen_issue_row_id = GogglesDb::Issue.for_user(@current_user).first(8).sample.id
  delete_btn = find("#frm-delete-row-#{@chosen_issue_row_id}")
  expect(delete_btn).to be_visible
  accept_confirm { delete_btn.click }
end

# USES:
# - @chosen_issue_row_id
When('I can see that the chosen issue row has been deleted') do
  expect(find('section#issues-grid table tbody', visible: true))
    .to have_no_css("#frm-delete-row-#{@chosen_issue_row_id}")
end
