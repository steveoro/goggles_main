# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7.3.05
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::TableRowComponent
  #
  # => Suitable for *any* AbstractLap <=
  #
  # Collapsible table row (tr) for lap data display.
  #
  # - collapse DOM ID: "laps<MIR_id>"
  #   (typically, to be triggered by an external MIR row component)
  #
  # === Known hack:
  # Multiple collapse rows will result having the same DOM ID.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - lap: the GogglesDb::Lap model instance to be displayed
    def initialize(lap:)
      super
      @lap = lap
    end

    # Skips rendering unless the lap instance is properly set
    def render?
      @lap.class.ancestors.include?(GogglesDb::AbstractLap)
    end

    protected

    # Returns the DOM ID for this component
    def dom_id
      "laps#{@lap&.parent_result_id}"
    end
  end
end
