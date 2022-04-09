# frozen_string_literal: true

Then('I am at my workshops page') do
  expect(page).to have_current_path(user_workshops_path, ignore_query: true)
end

Then('I see my workshops title') do
  find('section#my-workshops-title h4', text: I18n.t('home.my.workshops_title'), visible: true)
end

Then('I click on the first row to see the details of the first workshop') do
  first_row = find('section#data-grid table tr td.workshop_name a', visible: true)
  first_row.click
  wait_for_ajax(5) && sleep(1)
  find('.main-content#top-of-page #workshop-show-title', visible: true)
end

Then('I am at the show page for the details of the workshop') do
  # We don't care which detail row is:
  expect(current_path).to include(user_workshop_show_path(-1).gsub('-1', ''))
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_swimmer
Then('I visit the workshops page for the chosen swimmer') do
  visit(user_workshops_for_swimmer_path(@chosen_swimmer))
end

# Uses @chosen_team
Then('I visit the workshops page for the chosen team') do
  visit(user_workshops_for_team_path(@chosen_team))
end
#-- ---------------------------------------------------------------------------
#++

# Sets @search_filter & @filter_name
Then('I filter the workshops list by an earlier date than the first row present on the grid') do
  step('I make sure the filtering form for the datagrid is visible')
  workshop_date = find('section#data-grid table tbody tr td.workshop_date', visible: true).text
  expect(workshop_date).to be_present
  # Filter by an earlier date (makes the first row always visible, assuming the order isn't changed):
  @search_filter = (Date.parse(workshop_date) - 1.month).to_s
  @filter_name = 'workshop_date'
  fill_in('user_workshops_grid[workshop_date]', with: @search_filter)
  step('I submit the filters for the datagrid \'#new_user_workshops_grid\' waiting 10 secs tops for it to disappear')
end

# Sets @search_filter & @filter_name
Then('I filter the workshops list by a portion of the first name found on the grid') do
  step('I make sure the filtering form for the datagrid is visible')
  node = find('section#data-grid table tbody tr td.workshop_name a', visible: true)
  # Filter by the last portion of the first name found:
  @search_filter = node.text.split(': ').last
  expect(@search_filter).to be_present
  @filter_name = 'workshop_name'
  fill_in('user_workshops_grid[workshop_name]', with: @search_filter)
  step('I submit the filters for the datagrid \'#new_user_workshops_grid\' waiting 10 secs tops for it to disappear')
end

# Uses @search_filter & @filter_name
Then('I see the applied filter in the top row label and at least the first workshop in the list') do
  sleep(1)
  # Wait for both the data grid table the first column to be rendered:
  find('section#data-grid table tbody', visible: true)
  find('section#data-grid table tbody tr td.workshop_date', visible: true)
  label = find('#datagrid-top-row #filter-labels', visible: true)

  case @filter_name
  when 'workshop_date'
    # Check filter value presence in label:
    expect(label.text.strip).to include(@search_filter)
    # Check actual filter value reflected on to the grid:
    workshop_date = find('section#data-grid table tbody tr td.workshop_date', visible: true).text
    expect(Date.parse(workshop_date)).to be >= Date.parse(@search_filter)
  when 'workshop_name'
    # Check filter value presence in label:
    # (Value may be "compressed" in spaces: let's check just the beginning and the end)
    expect(label.text.strip).to include(@search_filter.split.first) && include(@search_filter.split.last)
    # Check actual filter value reflected on to the grid:
    workshop_name = find('section#data-grid table tbody tr td.workshop_name', visible: true).text
    expect(workshop_name).to include(@search_filter)
  end
end
#-- ---------------------------------------------------------------------------
#++
