# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
require 'webdrivers'

require_relative 'download_helpers'

# Add factories directly from core engine:
require 'factory_bot_rails'
FactoryBot.definition_file_paths << "#{GogglesDb::Engine.root}/spec/factories"
FactoryBot.reload

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
  config.save_path = 'tmp'

  # Capybara defaults to CSS3 selectors rather than XPath.
  # If you'd prefer to use XPath, just uncomment this line and adjust any
  # selectors in your step definitions to use the XPath syntax.
  # Capybara.default_selector = :xpath
  # config.default_selector = :xpath
end
# Capybara.save_path = 'tmp'

firefox_options = Selenium::WebDriver::Firefox::Options.new
firefox_options.args << '--headless'
firefox_profile = Selenium::WebDriver::Firefox::Profile.new
firefox_profile['browser.download.dir'] = DownloadHelpers::PATH.to_s
firefox_profile['browser.download.folderList'] = 2
firefox_profile['browser.helperApps.neverAsk.saveToDisk'] = 'text/csv' # Suppress "open with" dialog
firefox_options.profile = firefox_profile

chrome_prefs = {
  'download.default_directory' => DownloadHelpers::PATH,
  'download.directory_upgrade' => true,
  'download.prompt_for_download' => false,
  'plugins.plugins_disabled' => ['Chrome PDF Viewer']
}
#-- ---------------------------------------------------------------------------
#++

#
# ==  Driver configurations ==
#
# For each one of the following setups, just use the corresponding tag on the feature you'd like
# to test.
#

# === Local debug setups ===
#
# Use a physical browser instance (needs access to an xdisplay port). Very slow but useful for
# local debugging.

# ** Firefox **
Capybara.register_driver :physical_firefox do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end

# ** Chrome **
Capybara.register_driver :physical_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': [
        'disable-gpu', 'disable-popup-blocking',
        'window-size=1280,1024', '--enable-features=NetworkService,NetworkServiceInProcess'
      ],
      'prefs': chrome_prefs
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end
#-- ---------------------------------------------------------------------------
#++

# === Headless setups ===
#
# No display port required; faster: the way to go for CI builds.

# ** Firefox **
Capybara.register_driver(:headless_firefox) do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options: firefox_options
  )
end
# NOTE: Selenium webdriver using Firefox/headless currently has no real support for mobileEmulation.

# ** Chrome **
Capybara.register_driver(:headless_chrome) do |app|
  # This will probably be the next valid syntax for Capybara:
  # options = Selenium::WebDriver::Chrome::Options.new
  # %w(headless disable-gpu window-size=1280,1024 no-sandbox).each { |arg| options.add_argument(arg) }
  # Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: capabilities)
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu window-size=1280,800 no-sandbox --enable-features=NetworkService,NetworkServiceInProcess],
      'prefs': chrome_prefs
    },
    'loggingPrefs': { browser: 'ALL', client: 'ALL', driver: 'ALL', server: 'ALL' }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_iphone4) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPhone 4' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_iphone5) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPhone 5' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_iphone6) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPhone 6' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_iphone8) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPhone 8' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_iphonex) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPhone X' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_galaxys5) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'Galaxy S5' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_pixel2) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'Pixel 2' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_ipad) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPad' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver(:headless_chrome_ipadpro) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      'args': %w[headless disable-gpu disable-extensions --enable-features=NetworkService,NetworkServiceInProcess],
      'mobileEmulation': { 'deviceName': 'iPad Pro' }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end
#-- ---------------------------------------------------------------------------
#++

# Select the default driver or force it from the command prompt:
if ENV['CAPYBARA_DRV'].present?
  Capybara.default_driver     = ENV['CAPYBARA_DRV'].to_sym
  Capybara.javascript_driver  = ENV['CAPYBARA_DRV'].to_sym
  Capybara.current_driver     = ENV['CAPYBARA_DRV'].to_sym
else
  Capybara.default_driver     = :headless_chrome
  Capybara.javascript_driver  = :headless_chrome
  Capybara.current_driver     = :headless_chrome
end
Kernel.puts "\r\n*** Setting Capybara current driver as...: #{Capybara.current_driver} ***"
Capybara.default_max_wait_time = 5
Capybara.server_port = 3001
