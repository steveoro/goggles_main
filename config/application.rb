# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GogglesMain
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_record.schema_format :sql

    # Add load paths for this specific Engine:
    # (Prefer eager_load_paths over autoload_paths, since eager_load_paths are
    #  being used in production environment too)
    config.eager_load_paths << Rails.root.join('app', 'strategies').to_s
    # [Steve A.] When in doubt, to check out the actual resulting paths, open the console and type:
    #   $> puts ActiveSupport::Dependencies._eager_load_paths
    # ...Or...
    #   $> puts ActiveSupport::Dependencies.autoload_paths
  end
end
