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
  # Bullet gem specific configuration:
  # ============================================================================
  # (see https://github.com/flyerhzm/bullet)
  config.after_initialize do
    Bullet.enable = true
    # Pop up a JavaScript alert in the browser:
    # Bullet.alert = true
    # Log to the Bullet log file (Rails.root/log/bullet.log):
    Bullet.bullet_logger = true
    # Log warnings to your browser's console.log:
    Bullet.console = true

    # Pop up Growl warnings if your system has Growl installed:
    # Bullet.growl = true

    # Send XMPP/Jabber notifications to the receiver indicated:
    # Bullet.xmpp = {
    #   account: 'bullets_account@jabber.org',
    #   password: 'bullets_password_for_jabber',
    #   receiver: 'your_account@jabber.org',
    #   show_online_status: true
    # }

    # Add warnings directly to the Rails log:
    Bullet.rails_logger = true

    # Add other notifications:
    # Bullet.honeybadger = true
    # Bullet.bugsnag = true
    # Bullet.airbrake = true
    # Bullet.rollbar = true
    # Bullet.sentry = true

    # Adds the details in the bottom left corner of the page:
    # Bullet.add_footer = true

    # Stacktrace inclusion / exclusions:
    # Bullet.stacktrace_includes = ['your_gem', 'your_middleware']
    Bullet.stacktrace_includes = ['goggles_db']
    # Bullet.stacktrace_excludes = [
    #   'their_gem',
    #   'their_middleware',
    #   ['my_file.rb', 'my_method'], ['my_file.rb', 16..20]
    # ]

    # Add Slack notifications:
    # Bullet.slack = {
    #   webhook_url: 'http://some.slack.url',
    #   channel: '#default',
    #   username: 'notifier'
    # }

    # Raise errors, useful for making your specs fail unless they have optimized queries:
    # (For this to work, all the configuration boilerplate must be invoked also on test environment)
    # Bullet.raise = true

    # --- Bullet detectors: ---
    # (Each of these settings defaults to true)
    # Detect N+1 queries:
    # Bullet.n_plus_one_query_enable     = false

    # Detect eager-loaded associations which are not used:
    Bullet.unused_eager_loading_enable = false

    # Detect unnecessary COUNT queries which could be avoided with a counter_cache:
    # Bullet.counter_cache_enable        = false
  end
end
