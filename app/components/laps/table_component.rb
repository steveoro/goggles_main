# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7-0.5.01
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
    # - collapsed: (default: true) when +false+, it won't hide/collapse the lap sub-table at start
    def initialize(laps:, collapsed: true)
      super
      @laps = laps
      @collapsed = collapsed
    end

    # Skips rendering unless @laps is enumerable and orderable :by_distance
    def render?
      @laps.present? && @laps.respond_to?(:each) && @laps.respond_to?(:by_distance)
    end

    protected

    # Returns the parent association name of the abstract lap instance (memoized)
    def parent_association_name
      @parent_association_name ||= @laps&.first&.class&.parent_association_sym
    end

    # Returns last available lap instance (memoized)
    def last_lap
      @last_lap ||= @laps&.includes(parent_association_name)&.by_distance&.last
    end

    # Returns the DOM ID for this component
    def dom_id
      "laps-show#{parent_result&.id}"
    end

    # Returns the associated parent result instance (memoized)
    def parent_result
      @parent_result ||= last_lap&.parent_result
    end

    # Returns an additional closing lap row filled using the end result for the "timing from start",
    # and computing its delta using the actual last available lap.
    def closing_result_lap
      return unless last_lap && parent_result

      last_delta_timing = parent_result.to_timing - last_lap.timing_from_start
      result_lap = last_lap.dup.from_timing(last_delta_timing)
      result_lap.length_in_meters = parent_result.event_type.length_in_meters
      result_lap.minutes_from_start = parent_result.minutes
      result_lap.seconds_from_start = parent_result.seconds
      result_lap.hundredths_from_start = parent_result.hundredths
      result_lap
    end
  end
end
