# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7.3.05
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::TableComponent
  #
  # => Suitable for *any* AbstractLap <=
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

    protected

    # Returns the parent association name of the abstract lap instance (memoized)
    def parent_association_name
      @parent_association_name ||= @laps&.first&.class&.parent_association_sym
    end
  end
end
