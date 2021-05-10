# frozen_string_literal: true

# == SimpleCov: Test coverage report formatter ==
# [Steve A., 20201030]
# SimpleCov prepares a static HTML code-coverage report inside '/coverage';
# the formatter is used by both CodeClimate.com & CodeCov.io build configurations.
#
# - CodeCov repot........: sent by its gem if the ENV variable CODECOV_TOKEN is set
# - CodeClimate report...: sent by using its stand-alone 'cc-test-reporter' utility
# - CoverAlls report.....: no longer maintained & gem dependancy removed
#
# See: https://github.com/steveoro/goggles_db/wiki/HOWTO-dev-code_coverage_setup

require 'simplecov'
SimpleCov.start 'rails'
puts 'SimpleCov required and started.'

unless ENV['CODECOV_TOKEN'].to_s.empty?
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  puts 'CodeCov.io selected for reporting output.'
end

# Add DSL for "N+1 query" issues directly inside RSpec:
require 'n_plus_one_control/rspec'

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'devise' # NOTE: require 'devise' after require 'rspec/rails' (this allows to use devise test helpers)

# Add factories directly from core engine:
require 'factory_bot_rails'
FactoryBot.definition_file_paths << "#{GogglesDb::Engine.root}/spec/factories"
FactoryBot.reload

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.

# Add support files directly from Core engine and then from current app:
# Dir[GogglesDb::Engine.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

require 'view_component/test_helpers'

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Add custom request spec path for Grape APIs: (for a standard Rails API test suite these are expected to be in /spec/requests/)
  config.include(RSpec::Rails::RequestExampleGroup, type: :request, file_path: %r{spec/api})

  # Add helpers to get Devise working with RSpec:
  config.include(Devise::TestHelpers, type: :features)
  config.include(Devise::Test::ControllerHelpers, type: :view) # (<-- these helpers include the Devise.mappings)
  config.include(Devise::Test::IntegrationHelpers, type: :view) # (<-- whereas, these do not)
  config.include(Devise::Test::IntegrationHelpers, type: :request)
  config.include(Devise::Test::IntegrationHelpers, type: :controller)

  # Add ViewComponent helpers:
  config.include ViewComponent::TestHelpers, type: :component

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
