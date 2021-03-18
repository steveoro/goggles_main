# frozen_string_literal: true

# Capybara support wrapper module for custom AJAX-related timeout helper methods
#
# FIXME: CURRENTLY DOESN'T WORK WITH jQuery included with WebPacker
#
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
        # Output a progress char to signal that we are in wait-state if the format 'pretty'
        # has been added to the parameters:
        Kernel.putc 'w' if ARGV&.include?('pretty')
        break if finished_all_ajax_requests?
      end
    end
  end

  # Will check if jQuery is defined within current webdriver context
  # and return +true+ if there are AJAX connctions still active.
  #
  def finished_all_ajax_requests?
    active = page.evaluate_script <<-INLINE_DOC.strip.gsub(/\s+/, ' ')
      (function() {
        if (typeof jQuery != 'undefined') {
          return jQuery.active;
        }
        else {
          console.error(
            "Failed on the page: " +
            document.URL +
            " `jQuery` was `undefined`. " +
            "Unable to call `jQuery.active`."
          );

          /* Return 2 since this is a third condition (not 0/1) .*/
          return 2;
        }
      })()
    INLINE_DOC

    active&.zero?
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
