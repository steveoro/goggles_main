# frozen_string_literal: true

When('I am redirected to the Chrono setup page') do
  expect(current_url).to include('/chrono/new')
end

Given('I select {string} as the event container type') do |rec_type_label|
  wait_for_ajax && sleep(1)
  expected_type = rec_type_label =~ /meeting/i ? '1' : '2'
  if find('#rec_type').value.to_s != expected_type
    find('#rec_type + span > label.switch').click
    wait_for_ajax
  end
  expect(find('#rec_type').value).to eq(expected_type)
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

When('I type {string} as selection for the {string} pre-filled select field') do |manual_input_label, field_camelcase_name|
  find("##{field_camelcase_name}_select").select(manual_input_label)
end

# [Steve A.] This goes beyond simply reproducing user actions because most DbLookup components are based
# on the JS Select2 widget and are using a dedicated Stimulus JS controller that does multiple API fetches
# and presets all linked fields for the final form POST.
# The scripts are needed to preset the needed values even if the API lookups silently fail.
When('I type {string} as selection for the {string} Select2 field') do |manual_input_label, field_camelcase_name|
  # Add programmatically a custom Option to the dropdown and pre-select it:
  execute_script("var currOption = new Option(\"#{manual_input_label}\", 0, true, true); $('##{field_camelcase_name}_select').append(currOption).trigger('change');")
  wait_for_ajax
  # Open the dropdown
  find("#select2-#{field_camelcase_name}_select-container").click
  wait_for_ajax
  # Select the custom Option:
  find('.select2-dropdown input.select2-search__field').send_keys(manual_input_label, :enter)
  # Close the dropdown (will also clear the search input, but who cares given we're faking it anyway)
  find("#select2-#{field_camelcase_name}_select-container").click
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
  expect(find('#event_date').value).to eq(Time.zone.today.to_s)
end

When('I click on the go to chrono button') do
  find('#btn-rec-chrono').click
end

When('I am redirected to the Chrono recording page') do
  expect(current_url).to include('/chrono/rec')
end

When('I see that the chosen swimmer is shown in the chrono header') do
  expect(find('#rec-header').text).to include(@current_user.swimmer.complete_name)
    .and include(@current_user.swimmer.year_of_birth.to_s)
end

When('I see that the current date is shown in the chrono header') do
  expect(find('#rec-header').text).to include(Time.zone.today.to_s)
end

When('I see that {string} is included in the chrono header') do |manual_input_label|
  expect(find('#rec-header').text).to include(manual_input_label)
end
