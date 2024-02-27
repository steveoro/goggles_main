# frozen_string_literal: true

When('I am at the Chrono index page') do
  expect(page).to have_current_path(chrono_path, ignore_query: true)
end

When('I am redirected to the Chrono setup page') do
  expect(page).to have_current_path(chrono_new_path, ignore_query: true)
end

Given('I select {string} as the event container type') do |rec_type_label|
  wait_for_ajax && sleep(1)
  expected_type = /meeting/i.match?(rec_type_label) ? '1' : '2'
  if find_by_id('rec_type').value.to_s != expected_type
    find('#rec_type + span > label.switch').click
    wait_for_ajax
  end
  expect(find_by_id('rec_type').value).to eq(expected_type)
end

When('I see that my associated swimmer is already set as subject') do
  selected_option = find('#swimmer_select option')
  expect(selected_option['selected']).to eq('true')
  expect(selected_option['data-complete_name']).to eq(@current_user.swimmer.complete_name)
  expect(selected_option['data-year_of_birth']).to eq(@current_user.swimmer.year_of_birth.to_s)
  expect(selected_option['data-gender_type_id']).to eq(@current_user.swimmer.gender_type_id.to_s)
  expect(selected_option.text).to include(@current_user.swimmer.complete_name)
    .and include(@current_user.swimmer.year_of_birth.to_s)
end
# -----------------------------------------------------------------------------

When('I type {string} as selection for the {string} pre-filled select field') do |manual_input_label, field_camelcase_name|
  find("##{field_camelcase_name}_select", visible: true).select(manual_input_label)
end

When('I see that the {string} Select2 field is disabled') do |field_camelcase_name|
  expect(find("select##{field_camelcase_name}_select", visible: true)).to be_disabled
end

When('I see that the {string} Select2 field is enabled') do |field_camelcase_name|
  expect(find("select##{field_camelcase_name}_select", visible: true)).not_to be_disabled
end

# [Steve A.] This goes beyond simply reproducing user actions because most DbLookup components are based
# on the JS Select2 widget and are using a dedicated Stimulus JS controller that does multiple API fetches
# and presets all linked fields for the final form POST.
# The scripts are needed to preset the needed values even if the API lookups silently fail.
#
# SETS/SAVES:
# @select2_input_text as manual_input_label
When('I type {string} as selection for the {string} Select2 field') do |manual_input_label, field_camelcase_name|
  # Add programmatically a custom Option to the dropdown and pre-select it:
  execute_script("var currOption = new Option(\"#{manual_input_label}\", 0, true, true); $('##{field_camelcase_name}_select').append(currOption).trigger('change');")
  wait_for_ajax
  select2_search_box = '.select2-dropdown input.select2-search__field'
  select2_search_field = "#select2-#{field_camelcase_name}_select-container"

  # Open the dropdown with the Select2 search box:
  find(select2_search_field).click
  wait_for_ajax

  # Select the custom Option:
  expect(page).to have_css(select2_search_box)
  find(select2_search_box).send_keys(manual_input_label, :enter)
  @select2_input_text = manual_input_label # (for possible later reference)

  # Close the dropdown (will also clear the search input, but who cares given we're faking it anyway)
  find(select2_search_field).click if page.has_css?(select2_search_box)
  expect(page).to have_no_css(select2_search_box)

  # Fake the hidden input setup made by the component when the API call is successful:
  execute_script("$('##{field_camelcase_name}_label').val('#{manual_input_label}')")
  execute_script("$('##{field_camelcase_name}_id').val(0)")
  wait_for_ajax
end

When('I type {string} as free input for the {string} field') do |manual_input_label, field_camelcase_name|
  find("##{field_camelcase_name}").set(manual_input_label)
end

When('I see that {string} is already set as {string} field') do |manual_input_label, field_camelcase_name|
  expect(find("##{field_camelcase_name}").value).to eq(manual_input_label)
end

When('I see that the current date is already set as the date of the event') do
  expect(find_by_id('event_date').value).to eq(Time.zone.today.to_s)
end

When('I click on the go to chrono button') do
  # Fake button enabled state, normally validated by Stimulus JS controller (doesn't work here):
  execute_script("$('#btn-rec-chrono').prop('disabled', false)")
  wait_for_ajax
  find_by_id('btn-rec-chrono', visible: true).click
end

When('I am redirected to the Chrono recording page') do
  expect(current_url).to include('/chrono/rec')
end

When('I see that the chosen swimmer is shown in the chrono summary') do
  expect(find_by_id('chrono-summary').text).to include(@current_user.swimmer.complete_name)
    .and include(@current_user.swimmer.year_of_birth.to_s)
end

When('I see that the current date is shown in the chrono summary') do
  expect(find_by_id('chrono-summary').text).to include(Time.zone.today.to_s)
end

When('I see that {string} is included in the chrono summary') do |manual_input_label|
  expect(find_by_id('chrono-summary').text).to include(manual_input_label)
end

When('I click on the {string} button at the end of form step {string}') do |btn_type, step_name|
  btn = find(".step-forms#step-#{step_name} button.btn.btn-#{btn_type}")
  # Scroll down so that the button is fully clickable even on short displays:
  execute_script('window.scrollTo(0,1000)')
  wait_for_ajax
  expect(btn).to be_visible
  btn.click
  sleep(1)
end

Then('I see that form step {string} is displayed') do |step_name|
  step_node = find(".step-forms#step-#{step_name}") # auto-wait for the node to be rendered
  expect(step_node).to be_present
  find(".step-forms#step-#{step_name}", visible: true)
end
