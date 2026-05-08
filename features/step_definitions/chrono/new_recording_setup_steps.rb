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
  expect(find_by_id('swimmer_id', visible: :all).value.to_i).to be_positive
  expect(find_by_id('swimmer_complete_name', visible: :all).value).to eq(@current_user.swimmer.complete_name)
  expect(find_by_id('swimmer_year_of_birth').value).to eq(@current_user.swimmer.year_of_birth.to_s)
  expect(find_by_id('gender_type_id').value).to eq(@current_user.swimmer.gender_type_id.to_s)
end
# -----------------------------------------------------------------------------

When('I type {string} as selection for the {string} pre-filled select field') do |manual_input_label, field_camelcase_name|
  find("##{field_camelcase_name}_select", visible: true).select(manual_input_label)
end

When('I see that the {string} autocomplete field is disabled') do |field_camelcase_name|
  expect(find("select##{field_camelcase_name}_select", visible: true)).to be_disabled
end

When('I see that the {string} autocomplete field is enabled') do |field_camelcase_name|
  expect(find("select##{field_camelcase_name}_select", visible: true)).not_to be_disabled
end

# [Steve A.] This goes beyond simply reproducing user actions because most Autocomplete components are based
# on the JS TomSelect widget and are using a dedicated Stimulus JS controller that does multiple API fetches
# and presets all linked fields for the final form POST.
# The scripts are needed to preset the needed values even if the API lookups silently fail.
#
# SETS/SAVES:
# @autocomplete_input_text as manual_input_label
When('I type {string} as selection for the {string} autocomplete field') do |manual_input_label, field_camelcase_name|
  execute_script(<<~JS, field_camelcase_name, manual_input_label)
    const baseName = arguments[0]
    const label = arguments[1]
    const select = document.querySelector(`#${baseName}_select`)

    if (select) {
      let value = '0'
      let option = Array.from(select.options).find((node) => node.text === label)
      if (option) {
        value = option.value
      } else {
        option = new Option(label, value, true, true)
        select.appendChild(option)
      }

      if (select.tomselect) {
        if (!select.tomselect.options[value]) {
          select.tomselect.addOption({ id: value, text: label, label: label })
        }
        select.tomselect.setValue(value, true)
      } else {
        select.value = value
        select.dispatchEvent(new Event('change', { bubbles: true }))
      }

      const idField = document.querySelector(`#${baseName}_id`)
      if (idField) idField.value = value

      const labelField = document.querySelector(`#${baseName}_label`)
      if (labelField) labelField.value = label
    }
  JS
  @autocomplete_input_text = manual_input_label # (for possible later reference)
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
  execute_script("document.querySelector('#btn-rec-chrono').disabled = false")
  wait_for_ajax
  find_by_id('btn-rec-chrono', visible: true).click
  wait_for_ajax
  next if current_path.include?('/chrono/rec')

  # Fallback for environments where submit_tag click is intercepted by inline handlers.
  execute_script(<<~JS)
    const form = document.querySelector('#frm-chrono-new')
    if (form) {
      form.onsubmit = null
      form.removeAttribute('onsubmit')
      form.submit()
    }
  JS
end

When('I am redirected to the Chrono recording page') do
  expect(page).to have_current_path(%r{/chrono/rec}, wait: 10, url: true)
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
