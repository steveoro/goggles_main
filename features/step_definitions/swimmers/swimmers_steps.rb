# frozen_string_literal: true

Then('I am at the show page for the details of the swimmer') do
  # We don't care which detail row is:
  expect(current_path).to include(swimmer_show_path(-1).gsub('-1', ''))
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
  expect(current_path).to eq(swimmer_history_recap_path(@chosen_swimmer))
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

When('I click on random event type link on the history recap') do
  tbody = find('section#swimmer-history-recap table tbody', visible: true)
  expect(tbody).to be_present
  event_rows = find_all('tr.event-types', visible: true)
  expect(event_rows.count).to be_positive
  event_rows.sample.find('td.history-link a').click
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
  find('section#swimmer-history-detail', visible: true)
  expect(current_path).to match(%r{swimmers/#{@chosen_swimmer.id}/history/\d+})
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
  node.find_all('tr td.meeting_name a').sample.click
end
#-- ---------------------------------------------------------------------------
#++
