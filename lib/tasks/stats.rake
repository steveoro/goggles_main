# frozen_string_literal: true

#
# = Statistics helper tasks
#
#   - (p) FASAR Software 2007-2021
#   - for Goggles framework vers.: 7+
#   - author: Steve A.
#
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

    Options: [Rails.env=#{Rails.env}]
             [date=any_iso_date|<#{Date.today}>]
             [days=starting_days_from]

      - date: any ISO-formatted date to output just the stats for that particular day

      - days: number of days before the current date from which the stats must be computed

    The date parameter takes precedence over the number of days; thus, without options,
    this task will just output the stats for the current day.

    The output is also duplicated at the end in CSV format for ease of usage.

  DESC
  task daily: [:environment] do |_t|
    days_up_to = ENV.include?('days') ? ENV['days'].to_i : 0
    date = ENV.include?('date') ? ENV['date'] : Date.today

    # Output header:
    puts format(
      "\r\n|%12<date>s|%12<users>s|%12<reqs>s|%15<avg>s|",
      date: 'Date'.center(12), users: 'Users'.center(12),
      reqs: 'REQ'.center(12), avg: ' Avg. REQ/user '
    )
    puts ''.ljust(56, '-')
    csv_txt = ['Date,users,requests,req./user']

    # Output daily status:
    (date - days_up_to.days..Date.today).each do |curr_date|
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
end
