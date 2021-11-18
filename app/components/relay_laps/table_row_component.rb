# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.1.00
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::TableRowComponent
  #
  # Collapsible table row (tr) for relay lap data display.
  #
  # - collapse DOM ID: "laps<MRR_id>"
  #   (typically, to be triggered by an external MRR row component)
  #
  # === Known hack:
  # Multiple collapse rows will result having the same DOM ID.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - relay_swimmer: the GogglesDb::MeetingRelaySwimmer model instance to be displayed
    def initialize(relay_swimmer:)
      super
      @relay_swimmer = relay_swimmer
    end

    # Skips rendering unless the membere is properly set
    def render?
      @relay_swimmer.instance_of?(GogglesDb::MeetingRelaySwimmer)
    end

    protected

    # Returns the DOM ID for this component
    def dom_id
      "laps#{@relay_swimmer.meeting_relay_result_id}"
    end

    # Memoized correlated Swimmers/Laps
    def related_laps
      @related_laps ||= @relay_swimmer.meeting_relay_result
                                      .meeting_relay_swimmers
                                      .includes(:meeting, :swimmer, :stroke_type)
    end

    # Memoized Meeting instance
    def meeting
      @meeting ||= related_laps.first.meeting
    end

    # Memoized Swimmer instance
    def swimmer
      @swimmer ||= @relay_swimmer.swimmer
    end

    # WIP: move this into core DB
    def timing_from_start
      precending_laps = related_laps.by_order
                                    .where('relay_order <= ?', @relay_swimmer.relay_order)
      Timing.new(
        hundredths: precending_laps.sum(:hundredths),
        seconds: precending_laps.sum(:seconds),
        minutes: precending_laps.sum(:minutes)
      )
    end

    # Returns the DOM ID for this component
    def swimmer_text_label_with_age
      return '' unless swimmer && meeting

      "#{swimmer.complete_name} (#{swimmer.year_of_birth} ~ #{swimmer.age(meeting.header_date)})"
    end
  end
end
