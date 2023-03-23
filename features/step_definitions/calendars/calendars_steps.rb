# frozen_string_literal: true

When('I am at the Calendars {string} page') do |page_name|
  path_to_expect = case page_name
                   when 'current'
                     calendars_current_path
                   when 'starred'
                     calendars_starred_path
                   when 'starred_map'
                     calendars_starred_map_path
                   end
  expect(page).to have_current_path(path_to_expect)
end

Then('I can see the pagination controls on the calendar current page when there are enough rows') do
  # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:46)
  last_season = GogglesDb::Season.joins(meetings: :meeting_individual_results)
                                 .last_season_by_type(GogglesDb::SeasonType.mas_fin)
  if GogglesDb::Calendar.where(season_id: last_season.id).count > 10
    find('#pagination-top nav#paginator-controls')
    find('#pagination-bottom nav#paginator-controls')
  end
end
# -----------------------------------------------------------------------------

# Relies on @unexpired_calendars & @expired_calendars instead of checking the star button status
# (NOTE: for an alternative take on this, see the same step implementation for the team star context)
Then('I can see the calendar row star button enabled or disabled depending on the row status') do
  find('#data-grid table.table tbody tr', visible: true)
  find_all('#data-grid table.table tbody tr td.text-center span.user-star').each do |star_node|
    row_id = star_node['data-row-id'].to_i

    if @unexpired_calendars.pluck(:meeting_id).include?(row_id) # Unexpired? => must be enabled
      btn = find("#btn-row-star-#{row_id}")
      expect(btn).to be_present
      expect(btn).not_to have_css('disabled')
      expect(btn[:href]).to include(taggings_by_user_path(meeting_id: row_id))
    elsif @expired_calendars.pluck(:meeting_id).include?(row_id) # Expired? => disabled for sure
      expect(find("i#btn-row-star-#{row_id}.disabled")).to be_present
      # (else: pre-existing fixture rows: ignore for brevity)
    end
  end
end

Then('I cannot see the team row tag button available in any row') do
  find('#data-grid table.table tbody tr', visible: true)
  find_all('#data-grid table.table tbody tr td.text-center span.team-star').each do |star_node|
    row_id = star_node['data-row-id'].to_i
    expect(find("i#btn-team-star-#{row_id}.disabled")).to be_present
  end
end

Then('I can see the calendar team star button enabled or disabled depending on the row status') do
  find('#data-grid table.table tbody tr', visible: true)
  find_all('#data-grid table.table tbody tr td.text-center span.team-star').each do |star_node|
    row_id = star_node['data-row-id'].to_i
    meeting = GogglesDb::Meeting.find(row_id)
    # If the meeting isn't expired yet, the team-star button should be available
    # (assuming the current user has team management grants: we won't check them here)
    if meeting.header_date >= Time.zone.today
      btn = find("#btn-team-star-#{row_id}")
      expect(btn).to be_present
      expect(btn).not_to have_css('disabled')
    else
      expect(find("i#btn-team-star-#{row_id}.disabled")).to be_present
    end
  end
end
# -----------------------------------------------------------------------------

# Scans current calendar page & sets @chosen_calendar_row_id from enabled & untagged rows
When('I choose a row from the displayed calendar page to be starred for myself') do
  find('#data-grid table.table tbody tr', visible: true)
  enabled_row_stars = find_all('#data-grid table.table tbody tr td.text-center span.user-star').select do |star_node|
    row_id = star_node['data-row-id'].to_i
    meeting = GogglesDb::Meeting.find(row_id)
    # Unexpired & untagged yet:
    (meeting.header_date >= Time.zone.today) &&
      star_node.find("#btn-row-star-#{row_id} i")['class'].include?('fa fa-star-o')
  end
  expect(enabled_row_stars).to be_present
  @chosen_calendar_row_id = enabled_row_stars.sample['data-row-id']
  expect(@chosen_calendar_row_id).to be_present
end

# Scans current calendar page & sets @chosen_calendar_row_id from *already tagged* rows
When('I choose a row from the displayed calendar page to be unstarred') do
  find('#data-grid table.table tbody tr', visible: true)
  tagged_row_stars = find_all('#data-grid table.table tbody tr td.text-center span.user-star').select do |star_node|
    row_id = star_node['data-row-id'].to_i
    star_node.find("#btn-row-star-#{row_id} i")['class'].include?('fa fa-star')
  end
  expect(tagged_row_stars).to be_present
  @chosen_calendar_row_id = tagged_row_stars.sample['data-row-id']
  expect(@chosen_calendar_row_id).to be_present
end

# Scans current calendar page & sets @chosen_calendar_row_id from enabled & untagged rows
When('I choose a row from the displayed calendar page for team tagging') do
  find('#data-grid table.table tbody tr', visible: true)
  enabled_row_stars = find_all('#data-grid table.table tbody tr td.text-center span.team-star').select do |star_node|
    row_id = star_node['data-row-id'].to_i
    meeting = GogglesDb::Meeting.find(row_id)
    # Unexpired & untagged yet:
    (meeting.header_date >= Time.zone.today) &&
      star_node.find("#btn-team-star-#{row_id} i")['class'].include?('fa fa-calendar-o')
  end
  expect(enabled_row_stars).to be_present
  @chosen_calendar_row_id = enabled_row_stars.sample['data-row-id']
  expect(@chosen_calendar_row_id).to be_present
end
# -----------------------------------------------------------------------------

# Uses @chosen_calendar_row_id
Then('I click to tag for myself the chosen calendar row') do
  find("a#btn-row-star-#{@chosen_calendar_row_id} i").click
  wait_for_ajax && sleep(1) && wait_for_ajax
  find("a#btn-row-star-#{@chosen_calendar_row_id} i", visible: true)
  sleep(1) && wait_for_ajax
end
# -----------------------------------------------------------------------------

# Uses @chosen_calendar_row_id
# Relies on lexical distinction between row/user-stars = "stars" & team-tags = "tags"
Then(/I can see the chosen calendar row has been (starred|unstarred|tagged|untagged)/) do |word|
  btn_naming = %w[starred unstarred].include?(word) ? 'row' : 'team'
  hash_lookup = {
    'starred' => 'fa-star text-warning',
    'unstarred' => 'fa-star-o text-primary',
    'tagged' => 'fa-calendar text-success',
    'untagged' => 'fa-calendar-o text-secondary'
  }
  css_classes = hash_lookup[word]
  # Wait a bit for both modal animation & rendering of the changed tag (but break out if ready):
  10.times do
    sleep(1) && wait_for_ajax
    break if find("a#btn-#{btn_naming}-star-#{@chosen_calendar_row_id} i")['class'].include?("fa #{css_classes}")
  end
  expect(find("a#btn-#{btn_naming}-star-#{@chosen_calendar_row_id} i")['class']).to include("fa #{css_classes}")
end
# -----------------------------------------------------------------------------

# Uses @chosen_calendar_row_id
When('I click to tag the chosen calendar row for one of my teams') do
  find("a#btn-team-star-#{@chosen_calendar_row_id} i").click
  sleep(1) && wait_for_ajax
end

Then('the team star modal appears') do
  find_by_id('team-star-modal', class: 'modal', visible: true)
end

When('I select the first team on the list to be tagged for the calendar') do
  find_by_id('team_id').select(0)
end

When('I click the team selection modal to confirm the default selection') do
  find_by_id('btn-team-star-submit').click
  wait_for_ajax && sleep(1) && wait_for_ajax
end

# Uses @current_user
Then('I can see the pagination controls on the calendar starred page when there are enough rows') do
  if GogglesDb::Meeting.tagged_with("u#{@current_user.id}").count > 10
    find('#pagination-top nav#paginator-controls')
    find('#pagination-bottom nav#paginator-controls')
  end
end

Then('I can only see starred calendar rows') do
  find('#data-grid table.table tbody tr', visible: true)
  find_all('#data-grid table.table tbody tr td.text-center span.user-star').each do |star_node|
    row_id = star_node['data-row-id'].to_i
    btn = find("#btn-row-star-#{row_id}")
    expect(btn).to be_present
    expect(btn).not_to have_css('disabled')
    expect(btn[:href]).to include(taggings_by_user_path(meeting_id: row_id))
  end
end
# -----------------------------------------------------------------------------

Then('I see the calendars map container') do
  find_by_id('calendars-map', class: 'container', visible: true)
end

Then('I see the calendars nav link to go back to the starred list') do
  nav_link = find('section#calendars-map-navs ul.nav.nav-tabs li.nav-item a.nav-link', visible: true)
  expect(nav_link[:href]).to include(calendars_starred_path)
end
