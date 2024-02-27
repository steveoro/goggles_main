# frozen_string_literal: true

Then('I am at the show page for the details of the team') do
  # We don't care which detail row is:
  expect(page.current_path.to_s).to include(team_show_path(-1).gsub('-1', ''))
end

Then('I see the team\'s details table') do
  node = find('section#team-show-details table', visible: true)
  expect(node).to be_present
  expect(node.find('td#full-name').text).to be_present
  expect(node.find('td#address').text).to be_present
  expect(node.find('td#homepage').text).to be_present
end

Then('I see the team\'s details toolbar buttons') do
  node = find('section#team-buttons', visible: true)
  expect(node).to be_present
  expect(node.find('a#btn-swimmers').text).to be_present
  expect(node.find('a#btn-meetings').text).to be_present
  expect(node.find('a#btn-workshops').text).to be_present
end
#-- ---------------------------------------------------------------------------
#++

# Uses @chosen_team
Then('I see the team\'s name in the meeting or workshop list title') do
  expect(@chosen_team).to be_a(GogglesDb::Team).and be_valid
  node = find('section#all-meetings-title h4', visible: true)
  expect(node).to be_present
  expect(node.text).to include(@chosen_team.editable_name)
end
#-- ---------------------------------------------------------------------------
#++

Then('I am at the team swimmers page index for team ID {int}') do |team_id|
  expect(page.current_path.to_s).to include(team_current_swimmers_path(team_id))
end

Then('the list of swimmers is not displayed') do
  expect(page).to have_no_css('#swimmers-list table')
end

Then('I see the list of swimmers for team ID {int}') do |_team_id|
  expect(find('#swimmers-list table thead tr', visible: true)).to be_present
  expect(find('#swimmers-list table tbody tr', visible: true)).to be_present
  # (Currently don't care about how many rows are shown)
end
#-- ---------------------------------------------------------------------------
#++
