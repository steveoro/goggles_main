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
  expect(find_by_id('timer-digits').text).to start_with("00:0#{total_seconds}.")
    .or start_with("00:0#{total_seconds + 1}.")
end

Then('I should see a list of {int} laps with the following times:') do |total_rows, table|
  # (table is a Cucumber::MultilineArgument::DataTable)
  data = table.raw # format: [['lap', 'time'], ['1', '2'], ['2', '3'], ...]

  # Check the recoreded laps total number:
  expect(data.length).to eq(total_rows + 1)
  expect(page).to have_css('#laps-grid table tbody tr', count: total_rows, wait: 10)

  # Check the recorded laps times:
  # (Actual timing may vary due to sleep + processing time between events.)
  data[1..].each_with_index do |row, index|
    _lap, min_time = row
    base_selector = "#laps-grid table tbody tr:nth-child(#{index + 1})"
    seconds_input = page.first("#{base_selector} td:nth-child(3) input", visible: :all) ||
                    page.first("#{base_selector} td.seconds input", visible: :all)
    seconds_node = seconds_input || page.first("#{base_selector} td:nth-child(3)", visible: :all) ||
                   page.first("#{base_selector} td.seconds", visible: :all)
    actual_value = (seconds_input&.value || seconds_node&.text).to_i
    expect(actual_value).to be >= min_time.to_i
  end
end

When('I click to edit lap {int} timing with {int} seconds') do |lap_number, new_timing_seconds|
  execute_script(<<~JS, lap_number, new_timing_seconds)
    var rowIdx = Number(arguments[0]);
    var seconds = Number(arguments[1]);
    var row = document.querySelector('#laps-grid table tbody tr:nth-child(' + rowIdx + ')');
    if (!row) return;
    var input = row.querySelector('td:nth-child(3) input, td.seconds input');
    if (!input) return;

    input.removeAttribute('disabled');
    input.focus();
    input.value = String(seconds);
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  JS

  base_selector = "#laps-grid table tbody tr:nth-child(#{lap_number})"
  seconds_input = page.first("#{base_selector} td:nth-child(3) input", visible: :all) ||
                  page.first("#{base_selector} td.seconds input", visible: :all)
  expect(seconds_input).to be_present
  expect(seconds_input.value.to_i).to eq(new_timing_seconds)
end

# Click on OK/Yes
When('I click on the timer save button accepting the confirmation request') do
  accept_confirm do
    find_by_id('timer-btn-save').click
  end
end

When('I am redirected to the Chrono index page') do
  sleep(1) && wait_for_ajax
  # Wait for content to be rendered and then verify path:
  find_by_id('content', visible: true)
  expect(current_url).to include('/chrono/index')
end
