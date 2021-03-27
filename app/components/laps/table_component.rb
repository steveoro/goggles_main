# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::TableComponent
  #
  # Collapsible table body (+tbody+) for laps data display.
  #
  # - collapse DOM ID: "laps<MIR_id>"
  #   (typically, to be triggered by an external component)
  #
  # === Known hack:
  # Multiple collapse rows will result having the same DOM ID.
  #
  class TableComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - laps: the GogglesDb::Lap relation holding the list of laps to be displayed
    def initialize(laps:)
      super
      @laps = laps
    end

    # Skips rendering unless @laps is enumerable and orderable :by_distance
    def render?
      @laps.respond_to?(:each) && @laps.respond_to?(:by_distance)
    end
  end
end
