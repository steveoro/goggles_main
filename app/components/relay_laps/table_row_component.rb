# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.6.30
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::TableRowComponent
  #
  # Table row (tr) for relay lap data display.
  #
  # Visibility is controlled by the parent RelayLaps::TableComponent tbody collapse wrapper.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - relay_swimmer: the GogglesDb::MeetingRelaySwimmer model instance to be displayed
    def initialize(relay_swimmer:)
      @relay_swimmer = relay_swimmer
    end

    # Skips rendering unless the member is properly set
    def render?
      return false unless @relay_swimmer.respond_to?(:id) && @relay_swimmer.id.to_i.positive?

      @relay_swimmer.is_a?(GogglesDb::MeetingRelaySwimmer) ||
        @relay_swimmer.is_a?(GogglesDb::JsonRow)
    end

    protected

    # Memoized correlated Swimmers/Laps
    def related_laps
      @related_laps ||= if @relay_swimmer.respond_to?(:meeting_relay_result)
                          @relay_swimmer.meeting_relay_result.meeting_relay_swimmers
                        else
                          relay_laps
                        end
    end

    # Memoized Meeting instance
    def meeting
      @meeting ||= if @relay_swimmer.respond_to?(:meeting)
                     @relay_swimmer.meeting
                   else
                     @relay_swimmer.meeting_relay_result.meeting
                   end
    end

    # Memoized Swimmer instance
    def swimmer
      @swimmer ||= @relay_swimmer.swimmer
    end

    # Returns the laps for this relay leg, ordered by distance.
    def relay_laps
      return @relay_laps if defined?(@relay_laps)

      laps = @relay_swimmer.relay_laps
      @relay_laps = laps.respond_to?(:by_distance) ? laps.by_distance : laps.sort_by(&:length_in_meters)
    end

    # Returns the timing recorded from the start of this relay lap/phase
    def timing_from_start
      Timing.new(
        hundredths: @relay_swimmer.hundredths_from_start,
        seconds: @relay_swimmer.seconds_from_start,
        minutes: @relay_swimmer.minutes_from_start
      )
    end

    # Returns the year of birth and the approximate age for the swimmer.
    def swimmer_year_and_age_label
      return '' unless swimmer && meeting

      "(#{swimmer.year_of_birth} ~ #{swimmer.age(meeting.header_date)})"
    end
  end
end
