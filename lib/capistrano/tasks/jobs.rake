# frozen_string_literal: true

namespace :jobs do
  desc "Ensures Solid Queue worker is running on the target app (use 'status:jobs' before to check status)"
  task :start do
    puts("\r\n")
    on roles(:app) do
      info('Ensuring bin/jobs (Solid Queue) is running on the target container...')
      puts("\r\n")
      puts ["[ #{fetch(:app_service)} ]---".rjust(80, '-')] +
           capture(
             :docker,
             "exec #{fetch(:app_service)} sh -lc 'pgrep -af \"bin/jobs|solid_queue\" >/dev/null || (bin/jobs start >/tmp/solid_queue.log 2>&1 &)'"
           ).split("\n") +
           [''.rjust(80, '-')]
    end
  end
end
