# frozen_string_literal: true

desc 'Check the overall remote server status and stats'
task status: ['status:mailq', 'status:monit', 'status:mem', 'status:docker', 'status:weekly_stats', 'status:jobs'] do
  # no-op
end

namespace :status do
  desc 'Checks the status of the remote mail queue'
  task :mailq do
    puts("\r\n")
    on roles(:app) do
      info('***********************')
      info('**   📫 Mail queue   **')
      info('***********************')
      puts ''.rjust(80, '-')
      # See the mail queue:
      execute(:mailq)
      #
      # To remove all mail from the queue, use:
      # $> postsuper -d ALL
      #
      # To remove all mails in the deferred queue, use:
      # $> postsuper -d ALL deferred
    rescue StandardError
      info('Postfix or mailq installation not found!')
    end
  end

  desc 'Checks the remote monit report'
  task :monit do
    puts("\r\n")
    on roles(:app) do
      info('*********************')
      info('**    📺 Monit     **')
      info('*********************')
      puts [''.rjust(80, '-')] +
           capture(:monit, :report).split("\n") +
           [''.rjust(80, '-')]
      info('Production Server response status code: ')
      execute(:curl, '--write-out \'%{http_code}\' --silent --head --output /dev/null https://master-goggles.org')
      puts capture(:monit, :summary).split("\n")
    end
  end

  desc 'Checks the remote memory & disk status'
  task :mem do
    puts("\r\n")
    on roles(:app) do
      info('************************')
      info('**  💽 Memory & Disk  **')
      info('************************')
      puts [''.rjust(80, '-')] +
           capture(:free, '--mega -h').split("\n") +
           [''.rjust(80, '-')] +
           capture(:df, '-h -T -x squashfs').split("\n")
    end
  end

  desc 'Checks the remote Docker status'
  task :docker do
    puts("\r\n")
    on roles(:app) do
      info('*********************')
      info('**    📦 Docker    **')
      info('*********************')
      puts [''.rjust(80, '-')] +
           capture(:docker, 'images').split("\n") +
           [''.rjust(80, '-')] +
           capture(:docker, 'ps -a').split("\n")
    end
  end

  desc <<~DESC
    Outputs the latest 7-day usage stats for all non-API request.


    ** Parameter: **

    - days: '[7]' (default) or '[<ANY_NUMBER_OF_DAYS_BACK>]'


    ** Usage: **

      > cap <STAGE> status:weekly_stats[30]
      Returns the last 30-days range of daily stats

    Or simply:
      > cap <STAGE> status:weekly_stats
      Outputs last week daily stats.

  DESC
  task :weekly_stats, :days do |_t, args|
    days_tot = args[:days] || 7
    puts("\r\n")
    on roles(:app) do
      info('***********************')
      info('**  📈 Weekly stats  **')
      info('***********************')
      info("Days tot: #{days_tot}")
      puts ["\r\n"] +
           capture(
             :docker,
             "exec #{fetch(:app_service)} sh -c 'bundle exec rails stats:daily days=#{days_tot}'"
           ).split("\n")
    rescue StandardError
      info('Exception raised when connecting to the docker service!')
    end
  end

  desc 'Checks the remote DelayedJob/ActiveJob status'
  task :jobs do
    puts("\r\n")
    on roles(:app) do
      info('********************')
      info('**     ⚙ Jobs     **')
      info('********************')
      puts("\r\n")
      puts ["[ #{fetch(:app_service)} ]---".rjust(80, '-')] +
           capture(
             :docker,
             "exec #{fetch(:app_service)} sh -c 'bin/delayed_job status'"
           ).split("\n") +
           [''.rjust(80, '-')] +
           capture(
             :docker,
             "exec #{fetch(:app_service)} sh -c 'bundle exec rails jobs:count'"
           ).split("\n")
    end
  end
end
