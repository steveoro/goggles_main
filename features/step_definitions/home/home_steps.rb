# frozen_string_literal: true

require 'version'

When('I am at the root page') do
  expect(page).to have_current_path(root_path, ignore_query: true)
end

Then('I see the version of the app at the bottom of the page') do
  expect(find('section#footer').text).to include(Version::SEMANTIC)
end

Then('I see a link to read more information about the app') do
  expect(find('section#footer a#href-about')[:href]).to include(home_about_path)
end

Then('I see a link to read terms of use & privacy policy') do
  expect(find('section#footer a#href-privacy-policy')[:href]).to include(home_about_path(anchor: 'privacy-policy'))
end

Then('I see a link to the contact form') do
  expect(find('section#footer a#href-contact-us')[:href]).to include(home_contact_us_path)
end

Then('I see the search box ready to use') do
  expect(find('#search-box form')).to be_visible
  expect(find('#search-box form')).not_to be_disabled
end
# -----------------------------------------------------------------------------

Then('I see the {string} section') do |section_id|
  expect(find("##{section_id}")).to be_present.and be_visible
end

Then('I see the link to go back to the root page') do
  find_link(text: I18n.t('about.go_back'), visible: true)
end
# -----------------------------------------------------------------------------

When('I see the contact form') do
  find('#contact-us-box form#frm-contact-us', visible: true)
end

When('I fill in the contact form with a test message') do
  within('#contact-us-box form#frm-contact-us') do
    fill_in('body', with: 'This is a test message')
  end
end
# -----------------------------------------------------------------------------

Then('I am at my dashboard page') do
  expect(page).to have_current_path(home_dashboard_path, ignore_query: true)
end

# Checks if a button/link node id is either 'missing' or 'disabled' or not
Then('I see the button {string} {string}') do |button_id, status|
  case status
  when 'missing'
    expect(page).to have_no_css("##{button_id}")

  when 'disabled'
    btn = find("##{button_id}.disabled")
    expect(btn).to be_visible

  else
    btn = find("##{button_id}", visible: true)
    expect(btn).to have_no_css('.disabled')
  end
end
# -----------------------------------------------------------------------------

Then('I can see the main Jobs web UI page') do
  expect(page).to have_css('h1')
  expect(find('h1')).to have_content('Jobs')
  expect(find('table thead tr').text).to include('ID') && include('Status') && include('Queue') && include('Actions')
end
# -----------------------------------------------------------------------------
