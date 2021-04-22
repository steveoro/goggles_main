# frozen_string_literal: true

namespace :log do
  # Remote Tail log tool.
  desc <<~DESC
    Tails/follows a specified log file in the shared path or the production.log, if none is given.
    Press CTRL-C to stop following the file.

    The current deploy stage name defines which kind of log files you can tail ('production' or 'staging').


    ** Parameter: **

    - kind: '[api]', '[api_audit]' or nil


    ** Usage: **

      > cap <STAGE> log:tail
      To tail the Rails app log

    Or:
      > cap <STAGE> log:tail[api]
      To tail the Rails API log file

    Or:
      > cap <STAGE> log:tail[api_audit]
      To tail the api_audit.log file

    Remember that if you use zsh you'll need to format it with single quotes as:
      > cap <STAGE> 'log:tail[logfile]'

  DESC
  task :tail, :kind do |_t, args|
    log_type = args[:kind] || fetch(:rails_env)
    resulting_log_path = case log_type
                         when 'api'
                           "#{fetch(:log_api_path)}/#{fetch(:rails_env)}.log"
                         when 'api_audit'
                           "#{fetch(:log_api_path)}/api_audit.log"
                         else
                           "#{fetch(:log_path)}/#{fetch(:rails_env)}.log"
                         end
    on roles(:app) do
      puts "- Host........: #{host}"
      puts "- Rails env...: #{fetch(:rails_env)}"
      puts "- Stage.......: #{fetch(:stage)}"
      puts "- Log type....: #{log_type}"
      puts "- Log path....: #{resulting_log_path}"
      puts ''.rjust(80, '-')
      execute(:ls, "-l #{resulting_log_path}")
      info('*** CTRL-C to exit follow file ***')
      puts ''.rjust(80, '-')
      execute(:tail, "-f -n60 #{resulting_log_path}")
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
