# frozen_string_literal: true

When('I am at the FIN score & time calculator page') do
  expect(page).to have_current_path(tools_fin_score_path, ignore_query: true)
end

When('I select {string}, {string}, {string} and {string} as FIN score parameters') do |event_type, pool_type, category_type, gender_type|
  # Select the Select2 widget value & then set also its corresponding hidden field (non-interactable by Selenium)
  find_by_id('event_type_select').select(event_type)
  execute_script("$('#event_type_id').val('#{find_by_id('event_type_select').value}')")
  find_by_id('pool_type_select').select(pool_type)
  execute_script("$('#pool_type_id').val('#{find_by_id('pool_type_select').value}')")
  find_by_id('category_type_select').select(category_type)
  execute_script("$('#event_type_id').val('#{find_by_id('category_type_select').value}')")
  wait_for_ajax
  expect(find_by_id('event_type_id').value).to eq(find_by_id('category_type_select').value)
  expect(find_by_id('pool_type_id').value).to eq(find_by_id('pool_type_select').value)
  expect(find_by_id('event_type_id').value).to eq(find_by_id('category_type_select').value)

  # Standard select tag (interactable, already with correct parameter name):
  find_by_id('gender_type_id').select(gender_type)
end

When('I insert {int}, {int} and {int} as FIN target timing') do |minutes, seconds, hundredths|
  find_by_id('minutes').set(minutes)
  find_by_id('seconds').set(seconds)
  find_by_id('hundredths').set(hundredths)
end

When('I click on the request FIN target score button') do
  click_link_or_button('btn-fin-score')
  wait_for_ajax
end

Then('I can see a non-zero FIN target score result') do
  sleep(1)
  expect(find_by_id('score').value.to_i).to be_positive
end

When('I insert {int} as FIN target score') do |score|
  find_by_id('score').set(score)
end

When('I click on the request FIN target timing button') do
  click_link_or_button('btn-fin-timing')
  wait_for_ajax
end

Then('I can see a non-zero FIN target timing result') do
  sleep(1)
  target_timing = Timing.new(
    minutes: find_by_id('minutes').value.to_i,
    seconds: find_by_id('seconds').value.to_i,
    hundredths: find_by_id('hundredths').value.to_i
  )
  expect(target_timing.to_hundredths).to be_positive
end
