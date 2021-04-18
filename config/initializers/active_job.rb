# frozen_string_literal: true

# Set backend for ActiveJob serialization:
# Use a real queuing backend for Active Job (and separate queues per environment)
Rails.application.config.active_job.queue_adapter = :delayed_job unless Rails.env.test?
