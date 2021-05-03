# frozen_string_literal: true

desc 'Check the overall remote server status and stats'
task status: ['status:mailq', 'status:monit', 'status:mem', 'status:docker', 'status:weekly_stats'] do
  # no-op
end

namespace :status do
  desc 'Checks the status of the remote mail queue'
  task :mailq do
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
    end
  end

  desc 'Checks the remote monit report'
  task :monit do
    on roles(:app) do
      info('*********************')
      info('**    📺 Monit     **')
      info('*********************')
      puts [''.rjust(80, '-')] +
           capture(:monit, :report).split("\n") +
           [''.rjust(80, '-')]
      info('Production Server response status code: ')
      execute(:curl, '--write-out \'%{http_code}\' --silent --head --output /dev/null https://master-goggles.org')
    end
  end

  desc 'Checks the remote memory & disk status'
  task :mem do
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

  desc 'Outputs the latest 7-day usage stats for all non-API request'
  task :weekly_stats do
    on roles(:app) do
      info('***********************')
      info('**  📈 Weekly stats  **')
      info('***********************')
      puts [''.rjust(80, '-')] +
           capture(:docker, "exec #{fetch(:app_service)} sh -c 'bundle exec rails stats:daily days=7'").split("\n")
    end
  end
end
