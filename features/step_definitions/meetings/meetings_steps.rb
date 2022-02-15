# frozen_string_literal: true

Then('I am at my past meetings page') do
  expect(page).to have_current_path(meetings_path, ignore_query: true)
end

Then('I see my past meetings title') do
  find('section#my-past-meetings-title h4', text: I18n.t('home.my.past_title'), visible: true)
end

Then('I click on the first row to see the details of the first meeting') do
  first_meeting = find('section#data-grid table tr td.meeting_name a', visible: true)
  first_meeting.click
  5.times do
    sleep(1) && wait_for_ajax
    putc('.')
  end
  find('.main-content#top-of-page #meeting-show-title', visible: true)
  find('#meeting-show-results table.table thead tr th.mevent-separator', visible: true)
end

Then('I am at the show page for the details of the meeting') do
  # We don't care which detail row is:
  expect(current_path).to include(meeting_show_path(-1).gsub('-1', ''))
end
