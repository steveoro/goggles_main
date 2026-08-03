# frozen_string_literal: true

Given('the anonymous request limit is set to {int}') do |limit|
  row = GogglesDb::AppParameter.versioning_row
  row.settings(:app).max_anonymous_req = limit
  row.save!
end

Given('I have made {int} anonymous requests') do |count|
  # Use the default test IP for Capybara's rack_test driver
  stats_route = 'REQ-127.0.0.1'
  GogglesDb::APIDailyUse.create_or_find_by!(route: stats_route, day: Time.zone.today)
  GogglesDb::APIDailyUse.where(route: stats_route, day: Time.zone.today).update_all(count:) # rubocop:disable Rails/SkipsModelValidations
end

# Reset the anonymous request limit and clear the test IP's daily count
# to prevent contamination of other scenarios.
After('@throttle') do
  row = GogglesDb::AppParameter.versioning_row
  row.settings(:app).max_anonymous_req = GogglesDb::AppParameter::DEFAULT_MAX_ANONYMOUS_REQ
  row.save!
  GogglesDb::APIDailyUse.where(route: 'REQ-127.0.0.1', day: Time.zone.today).delete_all
end
