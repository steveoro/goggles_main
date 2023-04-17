# frozen_string_literal: true

# Sets up @unexpired_calendars & @expired_calendars with any row depending if the corresponding meeting is already expired or not
Given('there are at least {int} calendar rows available') do |tot_calendar_rows|
  @unexpired_calendars ||= []
  @expired_calendars ||= []
  # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:251)
  last_season = GogglesDb::Season.joins(meetings: :meeting_individual_results)
                                 .last_season_by_type(GogglesDb::SeasonType.mas_fin)
  GogglesDb::Calendar.for_season(last_season).each do |calendar|
    if calendar.meeting && calendar.meeting.header_date >= Time.zone.today # unexpired
      @unexpired_calendars << calendar
    elsif calendar.meeting
      @expired_calendars << calendar
      # Ignore any calendar row w/o a meeting link
    end
  end
  remaining_required_rows = tot_calendar_rows - @unexpired_calendars.count - @expired_calendars.count
  remaining_required_rows = 0 if remaining_required_rows.negative?

  remaining_required_rows.times do
    random_date = Time.zone.today + ([1, -1].sample * (60 + (15 * rand).to_i).days)
    fixture_meeting = FactoryBot.create(:meeting, season: last_season, header_date: random_date)
    calendar = FactoryBot.create(:calendar, meeting: fixture_meeting)
    if fixture_meeting.header_date >= Time.zone.today # unexpired
      @unexpired_calendars << calendar
    else
      @expired_calendars << calendar
    end
  end
end

# Fills @unexpired_calendars with any additional row
Given('at least {int} calendar rows are not expired') do |tot_calendar_rows|
  @unexpired_calendars ||= []
  # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:251)
  last_season = GogglesDb::Season.joins(meetings: :meeting_individual_results)
                                 .last_season_by_type(GogglesDb::SeasonType.mas_fin)
  remaining_required_rows = tot_calendar_rows - @unexpired_calendars.count
  remaining_required_rows = 0 if remaining_required_rows.negative?

  remaining_required_rows.times do
    unexpired_meeting = FactoryBot.create(
      :meeting,
      season: last_season,
      header_date: Time.zone.today + (20 + (11 * rand).to_i).days
    )
    @unexpired_calendars << FactoryBot.create(:calendar, meeting: unexpired_meeting)
  end
end

# Fills @expired_calendars with any additional row
Given('at least {int} calendar rows are expired') do |tot_calendar_rows|
  @expired_calendars ||= []
  # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:251)
  last_season = GogglesDb::Season.joins(meetings: :meeting_individual_results)
                                 .last_season_by_type(GogglesDb::SeasonType.mas_fin)
  remaining_required_rows = tot_calendar_rows - @expired_calendars.count
  remaining_required_rows = 0 if remaining_required_rows.negative?

  remaining_required_rows.times do
    expired_meeting = FactoryBot.create(
      :meeting,
      season: last_season,
      header_date: Time.zone.today - (50 + (11 * rand).to_i).days
    )
    @expired_calendars << FactoryBot.create(:calendar, meeting: expired_meeting)
  end
end

# Relies on @unexpired_calendars & @current_user
Given('at least {int} calendar rows are already starred for me') do |tot_calendar_rows|
  expect(@unexpired_calendars).to be_present
  expect(@unexpired_calendars.count).to be >= tot_calendar_rows

  @unexpired_calendars.sample(tot_calendar_rows).each do |calendar|
    expect(calendar.meeting).to be_a(GogglesDb::Meeting).and be_valid
    already_starred = calendar.meeting.tags_by_user_list.include?("u#{@current_user.id}")
    next if already_starred

    calendar.meeting.tags_by_user_list.add("u#{@current_user.id}")
    calendar.meeting.save!
  end
end
