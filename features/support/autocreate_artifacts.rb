# frozen_string_literal: true

# Cucumber support module for automatically creating timestamped screenshots
# in case of a failed scenario.
#
# Artifact storage is usually available on CI servers only for paying accounts
# and should be disabled when running, for instance, on Semaphore 2.0.
#
# - 'AUTO_ARTIFACTS' ENV variable = 1 => toggle this on (when running Cucumber)
# - 'ARTIFACTS_PATH' ENV variable = <some path> => set destination paths for the artifacts
#
# Default artifacts destination path is 'tmp/cucumber'.
#
module AutocreateArtifacts
  # Returns a timestamped destination pathname which is used as prefix string
  # for the actual filename of each generated artifact (page sources & screenshots).
  #
  # == Output path:
  # - <RAILS_ROOT>/tmp/cucumber (default); override with: ENV('ARTIFACTS_PATH')
  def timestamped_prefix_path
    time_now = Time.zone.now
    timestamp = "#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{format((time_now.usec / 1000).to_i.to_s, '%03d')}"
    destination_path = ENV.fetch('ARTIFACTS_PATH', Rails.root.join('tmp/cucumber'))
    "#{destination_path}/#{timestamp}"
  end

  # Stores both current page sources & screenshot into the destination path obtained
  # with #timestamped_prefix_path.
  #
  # Note that if this is called, for instance, inside a step definition and not
  # inside the header Scenario definition, the scenario context variable is usually +nil+.
  def save_timestamped_artifacts(page, scenario = nil)
    filename, line_number = if scenario.respond_to?(:location)
                              [File.basename(scenario.location.file), scenario.location.lines.first.to_s]
                            else
                              [page.current_path[1..].tr('/', ''), '']
                            end
    screenshot_pathname = "#{timestamped_prefix_path}-screen-#{filename}-#{line_number}.png"
    page_pathname = "#{timestamped_prefix_path}-page-#{filename}-#{line_number}.html"
    # Show the current driver as a debugging helper:
    log("\r\n=> Capybara driver during failure: #{Capybara.current_driver}")
    log("\r\nSaving artifacts...")
    begin
      log("\r\nScreenshot:  #{screenshot_pathname}")
      save_screenshot(screenshot_pathname)
      log("\r\nPage source: #{page_pathname}")
      save_page(page_pathname)
    rescue StandardError
      log("\r\nError: unable to store artifacts!")
    end
  end
end

World(AutocreateArtifacts)

After do |scenario|
  # Dump artifacts upon each failed scenario if the ENV variable is set:
  next unless ENV['AUTO_ARTIFACTS'] && scenario.failed?

  save_timestamped_artifacts(page, scenario)
end
