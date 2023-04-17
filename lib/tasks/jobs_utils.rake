# frozen_string_literal: true

#
# = ActiveJob utility tasks
#
#   - (p) FASAR Software 2007-2018-2021
#   - Goggles framework vers.:  7.03
#   - author: Steve A.
#
#   (ASSUMES TO BE rakeD inside Rails.root)
#
namespace :jobs do
  desc <<~DESC
    Printout the amount of current jobs per queue.

    Options: [Rails.env=#{Rails.env}]
  DESC
  task(count: [:environment]) do
    jobs_queues_hash = Delayed::Job.group(:queue, 'failed_at IS NULL').count
    # Resulting example => {["edit", 0]=>1, ["edit", 1]=>12}

    # Printout the job queues with the job count:
    puts "\r\n\r\n  *** ActiveJob / DelayedJob status ***"
    puts "\r\n"
    puts "+#{''.center(22, '-')}+--------+---------+"
    puts "| #{'QUEUE'.center(20)} | STATUS | JOB TOT |"
    puts "+#{''.center(22, '-')}+--------+---------+"
    jobs_queues_hash.each do |queue_key, job_count_value|
      queue_name = queue_key.first
      failed_description = queue_key.last.to_i.positive? ? '  OK  ' : 'FAILED'
      puts "| #{queue_name.center(20)} | #{failed_description} | #{job_count_value.to_s.rjust(7)} |"
    end
    puts "+#{''.center(22, '-')}+--------+---------+"
    puts "\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Spawns all the different types of required recurrent jobs (currently: ImportProcessorJob
    & IssueCleanerJob) which will end immediately if their corresponding target queues
    do not have any rows in it.

    This "one-shot" behaviour is mandatory for this task because it's supposed
    to be run periodically by an external cron job (typically every few minutes).

    Options: [Rails.env=#{Rails.env}]
  DESC
  task(recurrent_spawn: [:environment]) do
    puts "\r\n\t*** Spawning ImportProcessorJob ***"
    Delayed::Job.enqueue(ImportProcessorJob.new('iq'))
    Delayed::Job.enqueue(ImportProcessorJob.new('sql'))
    puts "\r\n\t*** Spawning IssueCleanerJob ***"
    Delayed::Job.enqueue(IssueCleanerJob.new('issue'))
    puts 'Done.'
  end
end
