# frozen_string_literal: true

#
# = Issues components module
#
#   - version:  7-0.6.20
#   - author:   Steve A.
#
module Issues
  #
  # = Issues::ReportMistakeButtonComponent
  #
  # Button link to /issues/new_type1b1
  #
  class ReportMistakeButtonComponent < ViewComponent::Base
    # Creates a new ViewComponent.
    #
    # == Params
    # - <tt>result_row</tt>: a valid instance of <tt>GogglesDb::AbstractResult</tt>;
    #   must be already serialized (not new).
    #
    # - <tt>can_manage</tt>: master flag to enable the rendering of the component; default: false
    #
    def initialize(result_row:, can_manage: false)
      super
      @result_row = result_row
      @can_manage = can_manage
    end

    # Skips rendering unless the required parameters are set
    def render?
      @can_manage &&
        (@result_row.is_a?(GogglesDb::AbstractResult) || @result_row.instance_of?(GogglesDb::MeetingRelayResult))
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
