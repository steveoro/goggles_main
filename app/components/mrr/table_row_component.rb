# frozen_string_literal: true

#
# = MRR components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module MRR
  #
  # = MRR::TableRowComponent
  #
  # Collapsible table row for MRR data display.
  #
  # Includes the rendering of relay swimmers collapsible tbody if this MRR has stored
  # any relay swimmers/laps.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - mrr: the GogglesDb::MeetingRelayResult model instance to be displayed
    def initialize(mrr:)
      super
      @mrr = mrr
    end

    # Skips rendering unless the member is properly set
    def render?
      @mrr.instance_of?(GogglesDb::MeetingRelayResult)
    end

    protected

    # Memoized lap (relay swimmer) presence
    def laps?
      @laps ||= @mrr.meeting_relay_swimmers.count.positive?
    end

    # Relay name; gives precedence to the Relay code, if present
    def relay_name
      @mrr.relay_code.presence || @mrr.team.editable_name
    end

    # Result score; gives precedence to the standard scoring system, if used
    def result_score
      @mrr.standard_points > 0.0 ? @mrr.standard_points : @mrr.meeting_points
    end
  end
end
