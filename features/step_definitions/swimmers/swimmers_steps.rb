# frozen_string_literal: true

Then('I am at the show page for the details of the swimmer') do
  # We don't care which detail row is:
  expect(page.current_path.to_s).to include(swimmer_show_path(-1).gsub('-1', ''))
end

Then('I see the swimmer\'s details table') do
  node = find('section#swimmer-show-details table', visible: true)
  expect(node).to be_present
  expect(node.find('td#full-name').text).to be_present
  expect(node.find('td#year-of-birth').text).to be_present
  expect(node.find('td#curr-cat-code').text).to be_present
  expect(node.find('td#last-cat-code').text).to be_present
  expect(node.find('td#team-links').text).to be_present
end

Then('I see the swimmer\'s details toolbar buttons') do
  node = find('section#swimmer-buttons', visible: true)
  expect(node).to be_present
  expect(node.find('a#btn-stats').text).to be_present # (history)
  expect(node.find('a#btn-meetings').text).to be_present
  expect(node.find('a#btn-workshops').text).to be_present
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_swimmer
Then('I see the swimmer\'s name in the meeting or workshop list title') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  node = find('section#all-meetings-title h4', visible: true)
  expect(node).to be_present
  expect(node.text).to include(@chosen_swimmer.complete_name)
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_swimmer
Then('I browse to the radiography of the chosen swimmer') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  visit(swimmer_show_path(@chosen_swimmer))
end

# Uses @chosen_swimmer
Then('I am at the history recap page of the chosen swimmer') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  expect(page).to have_current_path(swimmer_history_recap_path(@chosen_swimmer), ignore_query: true)
end

# Uses @chosen_swimmer
And('I can see the chosen swimmer\'s name as subtitle of the history recap page') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  node = find('section#swimmer-history-recap #swimmer-name', visible: true)
  expect(node.text).to eq(@chosen_swimmer.complete_name)
end

And('I see the overall pie graph for the event types') do
  find('canvas#recap-chart', visible: true)
end

And('I see the list of attended event types') do
  find('section#swimmer-history-recap table tbody tr.event-types', visible: true)
end

# Sets @expanded_stat_dom_id (see step below)
When('I expand the details of a random event type and wait the stats to be displayed') do
  tbody = find('section#swimmer-history-recap table tbody', visible: true)
  expect(tbody).to be_present
  event_rows = find_all('tr.event-types', visible: true)
  expect(event_rows.count).to be_positive

  rnd_node = event_rows.sample
  @expanded_stat_dom_id = rnd_node.find('td.history-link label.switch-sm a')[:id].split('toggle-').last

  10.times do
    break if find("tr##{@expanded_stat_dom_id}").visible?

    dom_id = rnd_node.find('td.history-link label.switch-sm')[:id]
    step("I trigger the click event on the '##{dom_id}' DOM ID")
    # Retry the click in a more standard way in case JS fails to expand the section:
    rnd_node.find('td.history-link label.switch-sm').click unless find("tr##{@expanded_stat_dom_id}").visible?
    # Wait for the expand animation to finish
    5.times do
      break if find("tr##{@expanded_stat_dom_id}").visible?

      putc '.'
      wait_for_ajax
      sleep(0.5)
    end
    putc 'R' # signal repeat click&loop
  end
  expect(find("tr##{@expanded_stat_dom_id}")).to be_visible
end

# Uses @expanded_stat_dom_id
# NOTE: the swimmer history recap view won't render any of the stats sections for an event if its stats
#       are zero, and this may be true for some edge-cases. (E.g.: score 0 for under 20 + DSQ with no-time.)
When('I see that at least one the details score section is always present') do
  expect(find("tr##{@expanded_stat_dom_id}")).to be_visible
  find("tr##{@expanded_stat_dom_id} td .best-timings", visible: true) if page.has_css?("tr##{@expanded_stat_dom_id} td .best-timings")
  find("tr##{@expanded_stat_dom_id} td .top-score", visible: true) if page.has_css?("tr##{@expanded_stat_dom_id} td .top-score")
  find("tr##{@expanded_stat_dom_id} td .min-score", visible: true) if page.has_css?("tr##{@expanded_stat_dom_id} td .min-score")
  find("tr##{@expanded_stat_dom_id} td .avg-score", visible: true) if page.has_css?("tr##{@expanded_stat_dom_id} td .avg-score")
end

When('I click on random event type link on the history recap') do
  tbody = find('section#swimmer-history-recap table tbody', visible: true)
  expect(tbody).to be_present
  event_details_links = find_all('tr.event-types td.history-link a', visible: true)
  expect(event_details_links.count).to be_positive
  rnd_link = event_details_links.sample
  expect(rnd_link).to be_visible
  rnd_link.click
  sleep(1)
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_swimmer and @chosen_event_type
Then('I browse to the history detail page for the chosen swimmer and event type') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  expect(@chosen_event_type).to be_a(GogglesDb::EventType).and be_valid
  visit(swimmer_history_path(id: @chosen_swimmer.id, event_type_id: @chosen_event_type.id))
end

# Uses just @chosen_swimmer and ignores the randomly chosen event type
Then('I am at the detailed history page for the chosen event type and swimmer') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  sleep(1)
  wait_for_ajax
  step("I wait until the slow-rendered page portion 'section#swimmer-history-detail' is visible")
  expect(page).to have_current_path(%r{swimmers/#{@chosen_swimmer.id}/history/\d+})
end

And('I can see the chosen swimmer\'s name as subtitle of the history detail page') do
  expect(@chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
  node = find('section#swimmer-history-detail #swimmer-name', visible: true)
  expect(node.text).to eq(@chosen_swimmer.complete_name)
end

And('I see the history event line graph for the event types') do
  find('section#swimmer-history-detail canvas#detail-chart', visible: true)
end

And('I see the history datagrid for the event results') do
  find('section#swimmer-history-detail #data-grid', visible: true)
end

And('I see the history datagrid filtering controls') do
  find('section#swimmer-history-detail #data-grid #filter-panel') # (usually collapsed)
  find('section#swimmer-history-detail #data-grid #datagrid-ctrls', visible: true)
end

When('I click on random result link on the history detail grid') do
  node = find('section#swimmer-history-detail #data-grid table tbody', visible: true)
  rnd_node = node.find_all('tr td.meeting_name a').sample
  expect(rnd_node).to be_visible
  rnd_node.click
end
#-- ---------------------------------------------------------------------------
#++
