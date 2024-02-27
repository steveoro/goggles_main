# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  config.action_mailer.perform_deliveries = true
  # Use this to disable delivery errors, and bad email addresses will be ignored:
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.action_mailer.delivery_method = :letter_opener
  # Action Mailer default URL, required by Devise:
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Discriminate between local assets:precompile runs for production/staging:
  config.assets.prefix = '/dev-assets'
  # ** Note: **
  # The path above will end up in /public after each dynamic recompilation.
  #
  # If precompiled assets are available, they will be served - even if they no longer
  # match the original (uncompiled) assets, and even on the development server.
  #
  # Ensure that the development server always compiles assets on-the-fly by configuring the
  # development environment to keep precompiled assets in a different location than production.
  # (Otherwise, any assets precompiled for use in production will clobber requests for them in development.)
  #
  # Note also that:
  # - The asset precompile task in your deployment tool (e.g., Capistrano) should be disabled.
  # - Any necessary compressors or minifiers must be available on your development system.

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

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
