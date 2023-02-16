# frozen_string_literal: true

#
# = WizardForm components module
#
#   - version:  7-0.3.40
#   - author:   Steve A.
#
module WizardForm
  #
  # = ProgressBarComponent
  #
  # Creates a bespoke progress bar for a wizard-like form, where each
  # progress step represent a step into overall form completion.
  #
  # Put this component inside a wizard-like form that uses the Stimulus JS
  # WizardFormController to manage the steps progress.
  #
  # This component already sets the WizardFormController target for the progress bar updates.
  #
  # The resulting component will have '#progress' as ID.
  #
  class ProgressBarComponent < ViewComponent::Base
    # Creates a new ViewComponent.
    #
    # == Supported options & defaults:
    # - titles: [string_title1, string_title2, ...]
    #   Array of short labels or titles, one for each progressive step; defaults to ['1', '2', '3']
    #
    # - icons: [string_icon1, string_icon2, ...]
    #   Array of strings or unicode icons, one for each progressive step; defaults to ["\u0031", "\u0032", "\u0033"]
    #
    def initialize(options = {})
      super
      @titles = options[:titles] || %w[1 2 3]
      @icons  = options[:icons]  || %w[\u0031\ufe0f \u0032\ufe0f \u0033\ufe0f]
    end

    # Skips rendering unless both the parameters are properly set
    def render?
      @titles.respond_to?(:count) && @icons.respond_to?(:count) &&
        @titles.count.positive? && @titles.count == @icons.count
    end
  end
end
