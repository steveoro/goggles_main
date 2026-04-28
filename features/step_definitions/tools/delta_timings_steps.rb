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
end

Then('I see {string} as the resulting delta-T value for row {int}') do |delta_t, index|
  row_selector = "#delta-#{index}"
  expect(page).to have_css(row_selector, visible: :all)
  expect(find(row_selector, visible: :all)).to have_text(delta_t)
end

When('I click on the compute delta-t TXT output button') do
  click_link_or_button('btn-output-deltas')
end

Then('the output delta text dialog appears') do
  expect(find_by_id('output-txt-modal')).to be_visible
end

Then('I see {string} as one of the output delta-T text values') do |delta_t|
  expect(find_by_id('output').value).to include('TXT')
    .and include("Δt: #{delta_t}")
    .and include('CSV')
    .and include(";`#{delta_t}`;")
end
