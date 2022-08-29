# frozen_string_literal: true

# Delayed::Worker.destroy_failed_jobs = true # default: true
Delayed::Worker.sleep_delay = 60 # idle time before next polling when the queue is empty
Delayed::Worker.max_attempts = 3 # default: 25
Delayed::Worker.max_run_time = 30.minutes
Delayed::Worker.read_ahead = 5 # default: read 5 jobs ahead when fetching work
Delayed::Worker.default_queue_name = 'default'
# Delayed::Worker.priority = 0 # default: 0 for all enqueued works
Delayed::Worker.delay_jobs = !Rails.env.test? # Make sure to disable backend for test environment
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
