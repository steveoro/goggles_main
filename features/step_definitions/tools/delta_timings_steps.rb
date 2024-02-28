# frozen_string_literal: true

When('I am at the delta-time calculator page') do
  expect(page).to have_current_path(tools_delta_timings_path, ignore_query: true)
end

When('I insert {int}, {int} and {int} in the timing row {int}') do |minutes, seconds, hundredths, index|
  find_by_id("m_#{index}").set(minutes)
  find_by_id("s_#{index}").set(seconds)
  find_by_id("h_#{index}").set(hundredths)
end

When('I click on the compute delta-t button') do
  click_link_or_button('btn-compute-deltas')
  wait_for_ajax
  sleep(0.5)
end

Then('I see {string} as the resulting delta-T value for row {int}') do |delta_t, index|
  expect(find("#delta-#{index}").text).to eq(delta_t)
end
