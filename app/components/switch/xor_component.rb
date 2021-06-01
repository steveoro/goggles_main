# frozen_string_literal: true

#
# = Switch components module
#
module Switch
  #
  # = Switch::XorComponent
  #
  #   - version:  7.02.18
  #   - author:   Steve A.
  #
  # Xor switch between 2 target options.
  # When a target is selected, the other one becomes hidden.
  #
  # Default: 'target1' (as DOM ID) will be visible while target_2 will be hidden.
  #
  # @see SwitchController#toggleTargets()
  #
  # === Supports:
  # - hidden value field that stores the current selection
  # - rounded/squared borders: use '.round' for rounded (default: squared)
  # - green/red background: use '.red' to override green default
  #
  class XorComponent < ViewComponent::Base
    # Internal stored value for when the switch is showing target area #1
    # (This must match app/components/switch_controller.js:78)
    TYPE_TARGET1 = 1

    # Internal stored value for when the switch is showing target area #2
    # (This must match app/components/switch_controller.js:78)
    TYPE_TARGET2 = 2

    # Creates a new ViewComponent
    #
    # == Params
    # - label1........: DOM ID for the span text/label associated with target1 (displayed on the left)
    # - target1.......: DOM ID of the target node #1
    # - label2........: DOM ID for the span text/label associated with target2 (displayed on the right)
    # - target2.......: DOM ID of the target node #2
    #
    # == Supported options & defaults:
    # - hidden_id: nil => DOM ID of the hidden field storing the current selected value (usable by a wrapping form)
    #                     (default = nil => do not render the hidden field at all)
    #
    # - class: ''      => CSS classes names for switch rendering customization
    #                     ('red', 'round', ...)
    def initialize(label1, target1, label2, target2, options = {})
      super
      @hidden_id = options[:hidden_id]
      @label1 = label1
      @label2 = label2
      @target1 = target1
      @target2 = target2
      @css_classes = options[:class] || ''
    end
  end
end
