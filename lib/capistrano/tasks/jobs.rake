# frozen_string_literal: true

namespace :jobs do
  desc "Executes 'delayed_job start' on the target app (use 'status:jobs' before to check status)"
  task :start do
    puts("\r\n")
    on roles(:app) do
      info('Starting bin/delayed_job on the target container...')
      puts("\r\n")
      puts ["[ #{fetch(:app_service)} ]---".rjust(80, '-')] +
           capture(
             :docker,
             "exec #{fetch(:app_service)} sh -c 'bin/delayed_job start'"
           ).split("\n") +
           [''.rjust(80, '-')]
    end
  end
end
