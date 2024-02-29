# frozen_string_literal: true

Then('I am at my past meetings page') do
  expect(page).to have_current_path(meetings_path, ignore_query: true)
end

Then('I see my past meetings title') do
  find('section#my-past-meetings-title h4', text: I18n.t('home.my.past_title'), visible: true)
end

Then('I click on the first row to see the details of the first meeting') do
  first_row = find('section#data-grid table tr td.meeting_name a', visible: true)
  first_row.click
  15.times do
    putc('.')
    sleep(1) && wait_for_ajax
    found = begin
      find('.main-content#top-of-page #meeting-show-title', visible: true)
    rescue StandardError
      false
    end
    break if found
  end
  find('.main-content#top-of-page #meeting-show-title')
  find('#meeting-show-results table.table thead.mevent-separator', visible: true)
end

# Uses @chosen_meeting
Then('I browse to see the selected meeting details') do
  visit(meeting_show_path(@chosen_meeting.id))
  sleep(1)
end

# Uses @chosen_meeting
Then('I browse to see the selected meeting team results page') do
  visit(meeting_team_results_path(@chosen_meeting.id))
end

# Uses @chosen_meeting
Then('I browse to see the selected meeting swimmer results page') do
  visit(meeting_swimmer_results_path(@chosen_meeting.id))
end

Then('I am at the show page for the details of the meeting') do
  # We don't care which detail row is:
  expect(page.current_path.to_s).to include(meeting_show_path(-1).gsub('-1', ''))
end

# Sets @chosen_meeting (from URL) & @chosen_mevent
Then('I choose a random event from the clickable list of the meeting') do
  # Instead of selecting a random node from the displayed list, let's get the current Meeting
  # and choose an actual random event row from the existing MIRs, so that we can be almost sure
  # the event section will be expanded to some results:
  current_meeting_id = current_url.split('/').last.to_i
  @chosen_meeting = GogglesDb::Meeting.find(current_meeting_id)
  @chosen_mevent = @chosen_meeting.meeting_individual_results
                                  .includes(:meeting_event)
                                  .last(20).sample.meeting_event
end

# Uses @chosen_mevent
Then('I click on the chosen meeting event section, waiting for it to load') do
  find("thead th a#btn-load-mev-#{@chosen_mevent.id}").click
  sleep(1) && wait_for_ajax

  10.times do
    wait_for_ajax
    if page.has_css?("thead th a#btn-load-mev-#{@chosen_mevent.id}")
      sleep(0.5)
      putc '-'
    else
      putc '+'
      break
    end
  end
end

# Uses @chosen_mevent
Then('I see the results of the chosen meeting event') do
  find("thead#mevent-#{@chosen_mevent.id}")
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_swimmer
Then('I visit the meetings page for the chosen swimmer') do
  visit(meetings_for_swimmer_path(@chosen_swimmer))
end

# Uses @chosen_team
Then('I visit the meetings page for the chosen team') do
  visit(meetings_for_team_path(@chosen_team))
end
#-- ---------------------------------------------------------------------------
#++

# Sets @search_filter & @filter_name
Then('I filter the meetings list by an earlier date than the first row present on the grid') do
  step('I make sure the filtering form for the datagrid is visible')
  meeting_date = find('section#data-grid table tbody tr td.meeting_date', visible: true).text
  expect(meeting_date).to be_present
  # Filter by an earlier date (makes the first row always visible, assuming the order isn't changed):
  @search_filter = (Date.parse(meeting_date) - 6.months).to_s
  @filter_name = 'meeting_date'
  fill_in('meetings_grid[meeting_date]', with: @search_filter)
  step('I submit the filters for the datagrid \'#new_meetings_grid\' waiting 10 secs tops for it to disappear')
end

# Sets @search_filter & @filter_name
Then('I filter the meetings list by a portion of the first name found on the grid') do
  step('I make sure the filtering form for the datagrid is visible')
  node = find('section#data-grid table tbody tr td.meeting_name a', visible: true)
  # Filter by the last portion of the first name found:
  @search_filter = node.text.split(': ').last
  expect(@search_filter).to be_present
  @filter_name = 'meeting_name'
  fill_in('meetings_grid[meeting_name]', with: @search_filter)
  step('I submit the filters for the datagrid \'#new_meetings_grid\' waiting 10 secs tops for it to disappear')
end

# Uses @search_filter & @filter_name
Then('I see the applied filter in the top row label and at least the first meeting in the list') do
  sleep(1)
  # Wait for both the data grid table the first column to be rendered:
  find('section#data-grid table tbody', visible: true)
  find('section#data-grid table tbody tr', visible: true)
  label = find('#datagrid-top-row #filter-labels', visible: true)

  case @filter_name
  when 'meeting_date'
    # Check filter value presence in label:
    expect(label.text.strip).to include(@search_filter)
    # Check actual filter value reflected on to the grid:
    meeting_date = find('section#data-grid table tbody tr td.meeting_date', visible: true).text
    expect(Date.parse(meeting_date)).to be >= Date.parse(@search_filter)
  when 'meeting_name'
    # Check filter value presence in label:
    # (Value may be "compressed" in spaces: let's check just the beginning and the end)
    expect(label.text.strip).to include(@search_filter.split.first) && include(@search_filter.split.last)
    # Check actual filter value reflected on to the grid:
    meeting_name = find('section#data-grid table tbody tr td.meeting_name', visible: true).text
    expect(meeting_name).to include(@search_filter)
  end
end
#-- ---------------------------------------------------------------------------
#++

# Designed for Meetings
# Uses: @chosen_meeting
# Sets: @chosen_mir & @chosen_mevent
Given('I have chosen a random result among the current meeting details') do
  @chosen_mir = @chosen_meeting.meeting_individual_results
                               .last(250)
                               .sample
  @chosen_mevent = @chosen_mir.meeting_event
end

# Designed for Meetings
# Uses: @chosen_meeting, @associated_team_id
# Sets: @chosen_mir & @chosen_mevent
Given('I have chosen a random row from the results of my associated team') do
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting)
  expect(@associated_team_id).to be_positive
  @chosen_mir = @chosen_meeting.meeting_individual_results
                               .where(team_id: @associated_team_id)
                               .last(250)
                               .sample
  @chosen_mevent = @chosen_mir.meeting_event
end

# Designed for Meetings
# Uses: @chosen_meeting & @current_user
# Sets: @chosen_mir & @chosen_mevent
Given('I have chosen a random row from my own results') do
  expect(@chosen_meeting).to be_a(GogglesDb::Meeting)
  expect(@current_user.swimmer_id).to be_present
  @chosen_mir = @chosen_meeting.meeting_individual_results
                               .includes(:meeting_event)
                               .where(swimmer_id: @current_user.swimmer_id)
                               .sample
  @chosen_mevent = @chosen_mir.meeting_event
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_mir
When('I click on the team name on the chosen result row, selecting it') do
  css_selector = "tbody.result-table-row#mir#{@chosen_mir.id} .team-result-link a"
  step("I wait until the slow-rendered page portion '#{css_selector}' is visible")
  expect(page).to have_css(css_selector)
  step("I trigger the click event on the '#{css_selector}' DOM ID")
end

# Uses @chosen_mir
When('I click on the swimmer name on the chosen result row, selecting it') do
  css_selector = "tbody.result-table-row#mir#{@chosen_mir.id} span.swimmer-results-link a"
  step("I wait until the slow-rendered page portion '#{css_selector}' is visible")
  expect(page).to have_css(css_selector)
  step("I trigger the click event on the '#{css_selector}' DOM ID")
end

# Uses @chosen_meeting
Then('I am at the chosen team results page for the current meeting') do
  sleep(1)
  wait_for_ajax
  find('section#meeting-team-results')
  step("I wait until the slow-rendered page portion 'section#meeting-team-results' is visible")
  expect(page.current_path.to_s).to include(meeting_team_results_path(@chosen_meeting.id))
end

# Uses @chosen_meeting
Then('I am at the chosen swimmer results page for the current meeting') do
  sleep(1)
  wait_for_ajax
  find('section#meeting-swimmer-results')
  step("I wait until the slow-rendered page portion 'section#meeting-swimmer-results' is visible")
  expect(page.current_path.to_s).to include(meeting_swimmer_results_path(@chosen_meeting.id))
end
#-- ---------------------------------------------------------------------------
#++

Then('I see the title with the link to go to the team radiography') do
  find('#team-header-title span#back-to-dashboard a', visible: true)
end

Then('I see the team results header') do
  find_by_id('team-results-header', visible: true)
end

Then('I see the team swimmers grid') do
  find_by_id('team-results-swimmers-grid', visible: true)
end

Then('I see the team events grid') do
  find_by_id('team-results-events-grid', visible: true)
end

Then('I see the title with the link to go to the swimmer radiography') do
  find('#swimmer-header-title span#back-to-dashboard a', visible: true)
end

Then('I see the swimmer results header table') do
  find('#swimmer-results-header table', visible: true)
end
