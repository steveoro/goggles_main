# frozen_string_literal: true

#
# = Switch components module
#
#   - version:  7.01
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
    # - target_id: the collapsed body DOM ID as target for the component
    def initialize(target_id:)
      super
      @target_id = target_id
    end
  end
end
