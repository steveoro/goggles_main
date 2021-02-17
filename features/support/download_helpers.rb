# frozen_string_literal: true

# Capybara support wrapper module for download-related helper methods.
# For Chrome-based drivers only.
#
module DownloadHelpers
  # Timeout before bailing out of the download process
  TIMEOUT = 10 unless defined? TIMEOUT

  # Default download directory
  PATH = Rails.root.join('tmp', 'downloads') unless defined? PATH

  module_function # (same as "extend self")

  # Returns the list of files in the download directory.
  def available_download_file_names
    Dir[PATH.join('*')]
  end

  # First file found in the download directory.
  def downloaded_filename
    available_download_file_names.first
  end

  # Retrieves the downloaded content, if available.
  def download_content
    wait_for_download
    File.read(downloaded_filename) if downloaded_filename
  end

  # Enables the download for headless Chrome.
  # Works only for the chrome-family of browsers and if the name of the current
  # Capybara driver contains is prefixed with the "headless" name in it.
  #
  # @see: https://github.com/SeleniumHQ/selenium/issues/5159
  #
  def enable_download_behavior
    return unless Capybara.current_driver.to_s =~ /headless/i

    bridge = page.driver.browser.send(:bridge)
    bridge.http.call(
      :post,
      "/session/#{bridge.session_id}/chromium/send_command",
      cmd: 'Page.setDownloadBehavior',
      params: { behavior: 'allow', downloadPath: DownloadHelpers::PATH }
    )
  end

  # Sleeps repeatedly until the download seems to be completed or the
  # default TIMEOUT value is reached, in which case this helper will force the
  # current step to fail.
  #
  # Requires accessibility to Cucumber session Page member variable for debugging purposes.
  #
  # By specifing the 'pretty' argument for the Cucumber run setup,
  # this helper will output a custom character ('d') on the console to signal the
  # download-wait state.
  #
  # === Params
  # - timeout_sec_override: override in seconds for the default TIMEOUT value
  #
  def wait_for_download(timeout_sec_override = TIMEOUT)
    enable_download_behavior
    Timeout.timeout(timeout_sec_override) do
      until downloaded?
        # Output a custom progress char to signal that we are in wait-state if the format 'pretty'
        # has been added to the parameters:
        Kernel.putc 'd' if ARGV&.include?('pretty')
        sleep 0.5
      end
    end
  rescue StandardError
    log("\r\n")
    log($ERROR_INFO)
    log(caller(0..5).join("\r\n"))
    log('=> wait_for_download timed-out')
  end

  def downloaded?
    available_download_file_names.any? && !downloading?
  end

  def downloading?
    # Check existance of the temp. download file created by Chrome:
    available_download_file_names.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    # Comment this on/off if you need to debug the contents of the downloaded files:
    FileUtils.rm_f(available_download_file_names)
  end
end
#-- ---------------------------------------------------------------------------
#++

# Cucumber-specifc integration:
World(DownloadHelpers) if respond_to?(:World)

Before do
  # Make sure path exists:
  FileUtils.mkdir_p(DownloadHelpers::PATH)
  clear_downloads
  enable_download_behavior
end

After do
  clear_downloads
end
