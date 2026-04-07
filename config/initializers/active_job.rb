# frozen_string_literal: true

# Set backend for ActiveJob serialization:
# Use Solid Queue as the queuing backend for Active Job (and separate queues per environment)
Rails.application.config.active_job.queue_adapter = :solid_queue unless Rails.env.test?
