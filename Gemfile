# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# [20210128] ActiveRecord 6.1 introduces too many changes for the current version
gem 'rails', '= 6.0.3.5'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
gem 'browser' # detect request.variant type depending on request.user_agent
gem 'daemons'
gem 'delayed_job_active_record'
# [Steve A.] Force a specific version of Devise, supporting OAuth2:
gem 'devise', github: 'heartcombo/devise', branch: 'ca-omniauth-2'
gem 'devise-i18n'
# Inherited data factories from DB engine, published also on production/staging
# to allow fixture creation for testing purposes when using production structure dumps:
gem 'factory_bot_rails'
gem 'ffaker'
gem 'font-awesome-rails'
gem 'goggles_db', git: 'https://github.com/steveoro/goggles_db'
gem 'haml-rails'
gem 'kaminari'
gem 'nokogiri' # (used explicitly for view specs)
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
# Twitter disabled for the time being (supports only OAuth 1a)
# gem 'omniauth-twitter'
# [Steve A.] CORS support shouldn't be needed here for the moment, so keep this commented out:
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'rest-client'
gem 'view_component', require: 'view_component/engine'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', require: false
  gem 'guard'
  gem 'guard-brakeman'
  gem 'guard-bundler', require: false
  gem 'guard-cucumber'
  gem 'guard-haml_lint'
  gem 'guard-inch'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-spring'
  gem 'haml_lint', require: false
  gem 'inch', require: false # grades source documentation
  gem 'listen', '~> 3.2'
  # [20210128] Rubocop 1.9.0 seems to have several issues currently
  gem 'rubocop', '= 1.8.1', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-rubocop'
  gem 'spring-watcher-listen'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'awesome_print' # color output formatter for Ruby objects
  gem 'brakeman'
  gem 'bullet'
  # gem 'byebug' # Uncomment and call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'letter_opener'
  gem 'pry'
  gem 'rspec'
  gem 'rspec-rails'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  # For CodeClimate: use the stand-alone 'cc-test-reporter' from the command line.
  gem 'codecov', require: false
  gem 'coveralls', require: false
  gem 'cucumber-rails', require: false
  gem 'n_plus_one_control'
  # n_plus_one_control adds a DSL to check for "N+1 queries" directly in test environment.
  # (Bullet works best just on development). Do not use memoized values for testing.
  # Example:
  #          expect { get :index }.to perform_constant_number_of_queries"
  gem 'selenium-webdriver'
  gem 'simplecov', '= 0.13.0', require: false
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
