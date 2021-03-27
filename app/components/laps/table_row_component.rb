# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::TableRowComponent
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
      @lap.instance_of?(GogglesDb::Lap)
    end

    protected

    # Returns the DOM ID for this component
    def dom_id
      "laps#{@lap.meeting_individual_result_id}"
    end

    # Memoized correlated Laps
    def related_laps
      @related_laps ||= @lap.meeting_individual_result.laps
    end

    # WIP: move this into core DB
    def timing_from_start
      # TEST THIS: / then include in lap model
      # if lap.seconds_from_start.present?
      #   Timing.new(
      #     hundredths: lap.hundredths_from_start,
      #     seconds: lap.seconds_from_start,
      #     minutes: lap.minutes_from_start
      #   )
      # else
      precending_laps = related_laps.by_distance
                                    .where('length_in_meters <= ?', @lap.length_in_meters)
      Timing.new(
        hundredths: precending_laps.sum(:hundredths),
        seconds: precending_laps.sum(:seconds),
        minutes: precending_laps.sum(:minutes)
      )
      # end
    end
  end
end
