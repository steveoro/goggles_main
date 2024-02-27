# frozen_string_literal: true

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = (ENV['DISABLE_SPRING'] == 'true') # 'false' needed for Spring auto-reload
  config.action_view.cache_template_loading = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  # Allow usage of "have_enqueued_job.on_queue(...)" during tests:
  config.active_job.queue_adapter = :test
  # Action Mailer default URL, required by Devise:
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # ============================================================================
  # Prosopite gem specific configuration: (Bullet alternative)
  # (see https://github.com/charkost/prosopite)
  # ============================================================================
  config.after_initialize do
    # [Steve, 20240221] Leave Prosopite disabled if it complains too much.
    Prosopite.enabled = false # default: true
    Prosopite.rails_logger = true
    # Prosopite.prosopite_logger = true # default: false
    Prosopite.raise = true
    Prosopite.ignore_queries = [/active_storage_|events_by_pool_types|taggings/i]

    # ============================================================================
    # Bullet gem specific configuration:
    # (see https://github.com/flyerhzm/bullet)
    # ============================================================================
    # [Steve, 20210128] Note: Bullet doesn't support ActiveRecord 6.1 yet
    # [Steve, 20240221] Leave Bullet disabled if it complains too much.
    Bullet.enable = true

    # Pop up a JavaScript alert in the browser:
    # Bullet.alert = true

    # Log to the Bullet log file (Rails.root/log/bullet.log):
    # Bullet.bullet_logger = true
    # Log warnings to your browser's console.log:
    Bullet.console = true

    Bullet.raise = true # raise an error if a query detector occurs
    Bullet.stacktrace_includes = ['goggles_db']

    # --- Bullet detectors: ---
    # (Each of these settings defaults to true)
    # Detect N+1 queries:
    # Bullet.n_plus_one_query_enable = false

    # Detect eager-loaded associations which are not used:
    Bullet.unused_eager_loading_enable = false

    # Detect unnecessary COUNT queries which could be avoided with a counter_cache:
    Bullet.counter_cache_enable = false
  end
end
