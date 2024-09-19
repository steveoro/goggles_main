# frozen_string_literal: true

#
# = Statistics helper tasks
#
#   - (p) FASAR Software 2007-2024
#   - for Goggles framework vers.: 7+
#   - author: Steve A.
#
# rubocop:disable Rails/Date
#-- ---------------------------------------------------------------------------
#++

namespace :stats do
  desc <<~DESC
      Deletes all stats rows older than the specified number of days,
      boundary excluded (up-to but not including the ending date).

    Options: [Rails.env=#{Rails.env}]
             [days=days_older_up_to|<7>]

      - days: the number of days before which all rows should be considered as
              "old enough" to be deleted.

  DESC
  task clear: [:environment] do
    puts '*** stats:clear ***'
    days_up_to = ENV.include?('days') ? ENV['days'].to_i : 7
    ending_date = Date.today - days_up_to.days
    puts "- days: #{days_up_to} => Keeping all stats between #{ending_date} .. #{Date.today}"
    old_rows = GogglesDb::APIDailyUse.where('day < ?', ending_date)
    puts "Found #{old_rows.count} old stats rows: clearing that up..."
    old_rows.delete_all
    puts 'Done.'
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
      Outputs the daily usage stats for a given date, or a list of stats going back
    a particular number of days.

    If no date or days are specified, the default is the current day.

    Together with the API usage stats, this will also output the overall data editing stats
    for all the registered users.

    Options: [Rails.env=#{Rails.env}]
             [date=any_iso_date|<Date.today.to_s>]
             [days=starting_days_from]

      - date: any ISO-formatted date to output just the stats for that particular day

      - days: number of days before the current date from which the stats must be computed

    The date parameter takes precedence over the number of days (thus, without options,
    this task will just output the stats for the current day).

    The output is also duplicated at the end of each table in CSV format for ease of usage.

  DESC
  task daily: [:environment] do |_t|
    days_up_to = ENV.include?('days') ? ENV['days'].to_i : 0
    date = ENV.include?('date') ? Date.parse(ENV['date']) : Date.today

    generate_daily_output_stats(days_up_to, date)
    generate_overall_user_stats
  end

  # Prints out the daily usage stats for a given date, or a list of stats going back
  # a particular number of days.
  # Using default parameter values this will just output the stats for the current day.
  #
  # == Parameters:
  # - days_up_to: number of days before the current date from which the stats must be computed;
  #               defaults to 0
  # - date: any ISO-formatted date to output just the stats for that particular day;
  #         defaults to Date.today
  def generate_daily_output_stats(days_up_to, date) # rubocop:disable Metrics/AbcSize
    # Output header:
    puts format(
      "\r\n|%12<date>s|%12<users>s|%12<reqs>s|%15<avg>s|",
      date: 'Date'.center(12), users: 'Users'.center(12),
      reqs: 'Page views'.center(12), avg: ' Avg. REQ/user '
    )
    puts ''.ljust(56, '-')
    csv_txt = ['Date,users,pages,req./user']

    # Output daily status:
    ((date - days_up_to.days)..Date.today).each do |curr_date|
      sum, count = compute_stats_for(curr_date)
      avg = count.positive? ? sum / count : 0
      csv_txt << "#{curr_date},#{count},#{sum},#{avg}"
      puts format(
        '|%12<date>s| %10<users>s | %10<reqs>s |%15<avg>s|',
        date: curr_date.to_s.center(12),
        users: count.positive? ? count : '-',
        reqs: sum.positive? ? sum : '-',
        avg: avg.positive? ? avg : '-'
      )
    end

    puts ''.ljust(56, '-')
    puts "\r\n"
    puts "\r\n[output as csv]:\r\n-----8<-----"
    puts csv_txt.join("\r\n")
    puts "\r\n-----8<-----"
    puts "\r\n"
  end

  # Computes daily stats for a specific date.
  #
  # == Params
  # - date: the date for which the tuple of counters must be computed
  #
  # == Returns
  # the [total_sum, total_rows] tuple for a specific date
  #
  def compute_stats_for(date)
    req_rows = GogglesDb::APIDailyUse.where('route LIKE ?', 'REQ-%').for_date(date)
    [req_rows.sum(:count), req_rows.count]
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prints out the overall editing stats for each registered user,
  # both as a text-formatted table and in CSV format.
  def generate_overall_user_stats # rubocop:disable Metrics/AbcSize
    # Output header for user stats:
    puts format(
      "\r\n|%8<user_id>s|%8<creates>s|%8<edits>s|%8<deletes>s|%8<tot>s|",
      user_id: 'user_id'.center(8), creates: 'CREATE'.center(8),
      edits: 'EDIT'.center(8), deletes: 'DELETE'.center(8), tot: 'Tot.'.center(8)
    )
    puts ''.ljust(46, '-')
    csv_txt = ['user_id,CREATE,EDIT,DELETE,Total']

    retrieve_editing_stats_per_user.each do |user_id, stats_hash|
      puts format(
        '|%8<user_id>s|%8<creates>s|%8<edits>s|%8<deletes>s|%8<tot>s|',
        user_id:,
        creates: stats_hash[:create_sum],
        edits: stats_hash[:edit_sum],
        deletes: stats_hash[:delete_sum],
        tot: stats_hash.values.sum
      )
      csv_txt << "#{user_id},#{stats_hash[:create_sum]},#{stats_hash[:edit_sum]},#{stats_hash[:delete_sum]},#{stats_hash.values.sum}"
    end

    puts ''.ljust(46, '-')
    puts "\r\n"
    puts "\r\n[output as csv]:\r\n-----8<-----"
    puts csv_txt.join("\r\n")
    puts "\r\n-----8<-----"
    puts "\r\n"
  end

  # Retrieves the overall editing stats all registered users.
  #
  # == Returns
  # the [total_sum, total_rows] tuple for a specific date
  #
  def retrieve_editing_stats_per_user
    result = {}

    GogglesDb::APIDailyUse.where(
      '(route LIKE ?) OR (route LIKE ?) OR (route LIKE ?)',
      'CREATE-%', 'EDIT-%', 'DELETE-%'
    ).order(:route).each do |req|
      # Special API action route counter format: "<action>-<entity>-<user_id>"
      user_id = req.route.to_s.split('-').last

      result[user_id] ||= { create_sum: 0, edit_sum: 0, delete_sum: 0 }
      result[user_id][:create_sum] += req.count if req.route.starts_with?('CREATE-')
      result[user_id][:edit_sum] += req.count if req.route.starts_with?('EDIT-')
      result[user_id][:delete_sum] += req.count if req.route.starts_with?('DELETE-')
    end

    result
  end
end
# rubocop:enable Rails/Date
