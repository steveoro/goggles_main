# frozen_string_literal: true

Then('I am at my workshops page') do
  expect(page).to have_current_path(user_workshops_path, ignore_query: true)
end

Then('I see my workshops title') do
  find('section#my-workshops-title h4', text: I18n.t('home.my.workshops_title'), visible: true)
end

Then('I click on the first row to see the details of the first workshop') do
  first_meeting = find('section#data-grid table tr td.workshop_name a', visible: true)
  first_meeting.click
  wait_for_ajax(5) && sleep(1)
  find('.main-content#top-of-page #workshop-show-title', visible: true)
end

Then('I am at the show page for the details of the workshop') do
  # We don't care which detail row is:
  expect(current_path).to include(user_workshop_show_path(-1).gsub('-1', ''))
end
