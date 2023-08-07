# frozen_string_literal: true

#
# = Switch components module
#
#   - version:  7-0.6.00
#   - author:   Steve A.
#
module Switch
  #
  # = Switch::RotatingComponent
  #
  # Collapse toggle switch.
  # Specify the collapsed body DOM ID as target for the component.
  #
  class RotatingComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    #
    # - <tt>target_id</tt>: a collapsed body DOM ID as target for the component; the component will toggle
    #   the collapse CSS class from the target, if available.
    #
    # - <tt>option_classes</tt>: additional CSS class names for customization.
    #
    def initialize(target_id:, option_classes: '')
      super
      @target_id = target_id
      @option_classes = option_classes
    end
  end
end
