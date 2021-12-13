# frozen_string_literal: true

Given('I should see the timer {string} button {string}') do |button_name, state_name|
  actual_dom_id = "#timer-btn-#{button_name}"
  expect(find(actual_dom_id).disabled?).to eq(state_name == 'disabled')
end

When('I click on the timer {string} button') do |button_name|
  actual_dom_id = "#timer-btn-#{button_name == 'start/stop' ? 'switch' : button_name}"
  find(actual_dom_id).click
end

# ASSUMES: total_seconds is just a single digit < 9
Then('I should see a minimum of {int} seconds for the total elapsed time') do |total_seconds|
  expect(find('#timer-digits').text).to start_with("00:0#{total_seconds}.")
    .or start_with("00:0#{total_seconds + 1}.")
end

Then('I should see a list of {int} laps with the following times:') do |total_rows, table|
  # (table is a Cucumber::MultilineArgument::DataTable)
  data = table.raw # format: [['lap', 'time'], ['1', '2'], ['2', '3'], ...]

  # Check the recoreded laps total number:
  expect(data.length).to eq(total_rows + 1)
  expect(all('#laps-grid table tbody tr').count).to eq(total_rows)

  # Check the recorded laps times:
  # (Actual timing may vary due to sleep + processing time between events.)
  data[1..].each_with_index do |row, index|
    _lap, min_time = row
    actual_value = find("#laps-grid table tbody tr:nth-child(#{index + 1}) td.seconds").text.to_i
    expect(actual_value).to be >= min_time.to_i
  end
end

When('I click to edit lap {int} timing with {int} seconds') do |lap_number, new_timing_seconds|
  find("#laps-grid table tbody tr:nth-child(#{lap_number}) td.seconds").click
  find("#laps-grid table tbody tr:nth-child(#{lap_number}) td.seconds input").set(new_timing_seconds.to_s)
  find("#laps-grid table tbody tr:nth-child(#{lap_number}) td.seconds input").native.send_keys(:return)
end

# Click on OK/Yes
When('I click on the timer save button accepting the confirmation request') do
  accept_confirm do
    find('#timer-btn-save').click
  end
end

When('I am redirected to the Chrono index page') do
  expect(current_url).to include('/chrono/index')
end
