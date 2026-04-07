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
    # Solid Queue job counting
    jobs_count = SolidQueue::Job.count
    scheduled_count = SolidQueue::ScheduledExecution.count
    ready_count = SolidQueue::ReadyExecution.count
    claimed_count = SolidQueue::ClaimedExecution.count
    failed_count = SolidQueue::FailedExecution.count

    # Printout the job queues with the job count:
    puts "\r\n\r\n  *** ActiveJob / Solid Queue status ***"
    puts "\r\n"
    puts "+#{''.center(22, '-')}+---------+"
    puts "| #{'QUEUE STATUS'.center(20)} | JOB TOT |"
    puts "+#{''.center(22, '-')}+---------+"
    puts "| #{'Scheduled'.center(20)} | #{scheduled_count.to_s.rjust(7)} |"
    puts "| #{'Ready'.center(20)} | #{ready_count.to_s.rjust(7)} |"
    puts "| #{'Claimed'.center(20)} | #{claimed_count.to_s.rjust(7)} |"
    puts "| #{'Failed'.center(20)} | #{failed_count.to_s.rjust(7)} |"
    puts "| #{'Total Jobs'.center(20)} | #{jobs_count.to_s.rjust(7)} |"
    puts "+#{''.center(22, '-')}+---------+"
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
    ImportProcessorJob.perform_later('iq')
    ImportProcessorJob.perform_later('sql')
    puts "\r\n\t*** Spawning IssueCleanerJob ***"
    IssueCleanerJob.perform_later('issue')
    puts 'Done.'
  end
end
