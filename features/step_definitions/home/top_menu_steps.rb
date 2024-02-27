# frozen_string_literal: true

When('I open the drop-down top menu to see the available commands') do
  find('section#content', visible: true)
  # Handle both large and small screens:
  menu_btn = find('#navbar-content ul li a#navbar-dropdown')
  unless menu_btn.visible?
    toggler = find('button.navbar-toggler')
    expect(toggler).to be_visible
    toggler.click
  end
  sleep(1) && wait_for_ajax
  expect(menu_btn).to be_visible
  menu_btn.click
end

Then('I should NOT see the {string} command') do |cmd_dom_id|
  expect(page).to have_no_css("#navbar-content a##{cmd_dom_id}")
end

Then('I should see the {string} command') do |cmd_dom_id|
  expect(find("#navbar-content a##{cmd_dom_id}")).to be_visible
end
