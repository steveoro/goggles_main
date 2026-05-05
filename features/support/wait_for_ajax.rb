# frozen_string_literal: true

# Capybara support wrapper module for custom async timeout helper methods.
module WaitForAjax
  # Waits for all AJAX requests to be completed.
  #
  # By specifing the 'pretty' argument for the Cucumber run setup,
  # this helper will output a custom character ('w') on the console to signal the wait state.
  #
  # The helper may force the current step to fail if the maximum timeout time is reached.
  #
  # === Params
  # - timeout_sec_override: override in seconds for the default max_wait_time of Capybara
  #
  def wait_for_ajax(timeout_sec_override = Capybara.default_max_wait_time)
    Timeout.timeout(timeout_sec_override) do
      loop do
        break if requests_finished?

        # Output a progress char to signal that we are in wait-state if the format 'pretty'
        # has been added to the parameters:
        Kernel.putc 'w' if ARGV&.include?('pretty')
        sleep(0.1)
      end
    end
  end

  # Checks if all async requests have completed.
  #
  # Uses Turbo busy-state + request tracker to detect pending requests.
  #
  # @return [Boolean] true if no pending requests
  #
  def requests_finished?
    result = page.evaluate_script(<<~JS)
      (function() {
        if (window.__requestTracker && typeof window.__requestTracker.isIdle === 'function') {
          if (!window.__requestTracker.isIdle()) {
            return false;
          }
        }
        if (document.documentElement.hasAttribute('aria-busy')) {
          return false;
        }
        if (document.querySelector('turbo-frame[busy], form[aria-busy="true"]')) {
          return false;
        }
        return document.readyState === 'complete';
      })()
    JS

    result == true
  end

  # Waits for a specific URL path change after triggering navigation.
  #
  # Useful when clicking links that trigger Turbo navigation where the URL
  # change indicates completion.
  #
  # @param initial_path [String] The path before navigation was triggered
  # @param timeout_sec_override [Integer] Maximum seconds to wait
  # @return [Boolean] true when path has changed
  #
  def wait_for_navigation(initial_path, timeout_sec_override = Capybara.default_max_wait_time)
    Timeout.timeout(timeout_sec_override) do
      sleep(0.1) while current_path == initial_path
    end
    # Additional stabilization for page to render
    sleep(0.3)
    true
  rescue Timeout::Error
    warn "[wait_for_navigation] Timed out waiting for navigation from #{initial_path}"
    false
  end

  # Repeats a wait loop until the timeout is reached or the condition/result value
  # specified in the block is true.
  #
  # @param timeout_sec_override [Integer] Maximum seconds to wait
  # @yield Block that returns true when condition is met
  # @return [Boolean] true if condition was met
  #
  def wait_for_condition(timeout_sec_override = Capybara.default_max_wait_time)
    Timeout.timeout(timeout_sec_override) do
      loop do
        sleep(0.2)
        break if yield
      end
    end
    true
  rescue Timeout::Error
    false
  end

  # Makes sure the Loading spinner overlay is toggled off.
  #
  # @param timeout_sec_override [Integer] Maximum seconds to wait
  # @return [Boolean] true if spinner is off
  #
  def make_sure_spinner_overlay_is_off(timeout_sec_override = Capybara.default_max_wait_time)
    wait_for_condition(timeout_sec_override) do
      if page.has_css?('#spinner', visible: true)
        begin
          page.execute_script('toggleWaitSpinnerOff()')
        rescue StandardError
          nil
        end
        wait_for_ajax
      end
      !page.has_css?('#spinner', visible: true)
    end
  end

end
#-- ---------------------------------------------------------------------------
#++

# RSpec integration:
RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end

# Cucumber integration:
World(WaitForAjax) if respond_to?(:World)
