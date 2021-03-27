# frozen_string_literal: true

#
# = MIR components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module MIR
  #
  # = MIR::TableRowComponent
  #
  # Collapsible table row for MIR data display.
  #
  # Includes the rendering of laps collapsible tbody if this MIR has stored laps.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - mir: the GogglesDb::MeetingIndividualResult model instance to be displayed
    def initialize(mir:)
      super
      @mir = mir
    end

    # Skips rendering unless the member is properly set
    def render?
      @mir.instance_of?(GogglesDb::MeetingIndividualResult)
    end

    protected

    # Memoized lap presence
    def laps?
      @laps ||= @mir.laps.count.positive?
    end

    # Result score; gives precedence to the standard scoring system, if used
    def result_score
      @mir.standard_points > 0.0 ? @mir.standard_points : @mir.meeting_points
    end
  end
end
