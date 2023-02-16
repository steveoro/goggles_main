# frozen_string_literal: true

require 'version'

#
# = Footer components module
#
#   - version:  7-0.4.25
#   - author:   Steve A.
#
module Footer
  #
  # = Footer::MainComponent
  #
  # Renders the main footer, typically shown on the index of the landing page.
  # Includes the current version number.
  #
  class MainComponent < ViewComponent::Base
    protected

    # Returns the first locale available besides the current one.
    #
    # (Not an actual "locale switch" generic enough to sat aside as a
    # stand-alone component, but given that we won't probably never have
    # more than 2 locales, it's enough for now.)
    def other_locale_code
      I18n.available_locales.reject { |sym| sym == I18n.locale }.first
    end

    def unicode_locale_flag(locale_sym)
      locale_sym == :it ? 'Cambia in 🇮🇹' : 'Change to 🇬🇧'
    end
  end
end
