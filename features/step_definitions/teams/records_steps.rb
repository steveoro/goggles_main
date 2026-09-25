# frozen_string_literal: true

# The all-time records query ranks the whole results view and can take several
# seconds on the first (cold) page load, so readiness checks for this page use
# explicit generous wait times instead of the default max wait time.
Then('I wait up to {int} seconds for the {string} element to appear') do |seconds, css_selector|
  expect(find(css_selector, visible: true, wait: seconds)).to be_present
end

Then('I am at the team records page for team ID {int}') do |team_id|
  expect(page.current_path.to_s).to include(team_records_path(team_id))
end

Then('the team records page is not displayed') do
  expect(page).to have_no_css('#records-accordion')
end

Then('I see the team records tabs') do
  node = find('section#records-navs ul.nav-tabs', visible: true)
  expect(node.find('a#tab-all-time').text).to be_present
  expect(node.find('a#tab-by-season').text).to be_present
end

# The 4 collapsible grids are: pool 25m/50m x female/male
Then('I see the 4 pool x gender team records grids') do
  4.times do |index|
    expect(find("#records-title-#{index}", visible: true)).to be_present
    expect(find("#records-body-#{index}", visible: :all)).to be_present
  end
end

When('I expand the first team records grid') do
  click_button('btn-records-grid-0')
  wait_for_ajax
end

Then('I see its events x categories matrix with record cells') do
  grid = find('#records-body-0 table', visible: true)
  expect(grid).to be_present
  # Category codes as columns; first column is the event label:
  expect(grid.find('thead tr', visible: true).all('th').count).to be > 1
  # At least one populated cell: timing links to the meeting program anchor,
  # swimmer name links to the swimmer radiography page:
  expect(grid.find("td a[href*='#mprg-']", visible: :all)).to be_present
  expect(grid.find("td a[href*='/swimmers/show/']", visible: :all)).to be_present
end

Then('I see the PDF export button') do
  expect(find_by_id('btn-records-pdf', visible: true)).to be_present
end

Then('I see the season year selector') do
  expect(find('section#records-season-selector select#season_year', visible: true)).to be_present
  expect(find('section#records-season-selector #btn-filter-season', visible: true)).to be_present
end

When('I select a different season year for the selector') do
  select_node = find('section#records-season-selector select#season_year', visible: true)
  options = select_node.all('option').map(&:text)
  expect(options.count).to be > 1
  # Select the last (oldest) available championship year to actually change the filter:
  select_node.select(options.last)
end

Then('a PDF file for the team records grids is downloaded') do
  wait_for_download
  expect(downloaded_filename).to include('team-records-').and include('.pdf')
  expect(File.read(downloaded_filename, 4)).to eq('%PDF')
end
