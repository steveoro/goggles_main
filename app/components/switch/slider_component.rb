# frozen_string_literal: true

#
# = Switch components module
#
module Switch
  #
  # = Switch::SliderComponent
  #
  #   - version:  7.01
  #   - author:   Steve A.
  #
  # Generic boolean switch.
  #
  # === Supports:
  # - rounded/squared borders: use '.round' for rounded (default: squared)
  # - green/red background: use '.red' to override green default
  #
  # === Usage as a collapse toggle:
  # Use default options.
  #
  # === Usage for boolean form values:
  # WIP
  #
  class SliderComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - target_id: the collapsed body DOM ID as target for the component
    # - option_classes: CSS classes names for customization
    def initialize(target_id:, option_classes: '')
      super
      @target_id = target_id
      @option_classes = option_classes
    end
  end
end
