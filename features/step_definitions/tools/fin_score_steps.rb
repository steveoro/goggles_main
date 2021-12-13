# frozen_string_literal: true

When('I select {string}, {string}, {string} and {string} as FIN score parameters') do |event_type, pool_type, category_type, gender_type|
  # Select the Select2 widget value & then set also its corresponding hidden field (non-interactable by Selenium)
  find('#event_type_select').select(event_type)
  execute_script("$('#event_type_id').val('#{find('#event_type_select').value}')")
  find('#pool_type_select').select(pool_type)
  execute_script("$('#pool_type_id').val('#{find('#pool_type_select').value}')")
  find('#category_type_select').select(category_type)
  execute_script("$('#event_type_id').val('#{find('#category_type_select').value}')")
  wait_for_ajax
  expect(find('#event_type_id').value).to eq(find('#category_type_select').value)
  expect(find('#pool_type_id').value).to eq(find('#pool_type_select').value)
  expect(find('#event_type_id').value).to eq(find('#category_type_select').value)

  # Standard select tag (interactable, already with correct parameter name):
  find('#gender_type_id').select(gender_type)
end

When('I insert {int}, {int} and {int} as FIN target timing') do |minutes, seconds, hundredths|
  find('#minutes').set(minutes)
  find('#seconds').set(seconds)
  find('#hundredths').set(hundredths)
end

When('I click on the request FIN target score button') do
  click_button('btn-fin-score')
  wait_for_ajax
end

Then('I can see a non-zero FIN target score result') do
  sleep(1)
  expect(find('#score').value.to_i).to be_positive
end

When('I insert {int} as FIN target score') do |score|
  find('#score').set(score)
end

When('I click on the request FIN target timing button') do
  click_button('btn-fin-timing')
  wait_for_ajax
end

Then('I can see a non-zero FIN target timing result') do
  sleep(1)
  target_timing = Timing.new(
    minutes: find('#minutes').value.to_i,
    seconds: find('#seconds').value.to_i,
    hundredths: find('#hundredths').value.to_i
  )
  expect(target_timing.to_hundredths).to be_positive
end
