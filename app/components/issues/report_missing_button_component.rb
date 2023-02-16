# frozen_string_literal: true

#
# = Issues components module
#
#   - version:  7-0.4.25
#   - author:   Steve A.
#
module Issues
  #
  # = Issues::ReportMissingButtonComponent
  #
  # Button link to /issues/new_type1b
  #
  class ReportMissingButtonComponent < ViewComponent::Base
    # Creates a new ViewComponent.
    #
    # == Options:
    # All non-boolean options need to be valid, serialized rows (not new)
    #
    # - <tt>parent_meeting</tt>: associated parent <tt>GogglesDb::AbstractMeeting</tt>.
    #
    # - <tt>event_type</tt>: preselected <tt>GogglesDb::EventType</tt>; it can be changed
    #   later in the form, choosing among the events of the meeting.
    #
    def initialize(options = {})
      super
      @parent_meeting = options[:parent_meeting]
      @event_type = options[:event_type]
    end

    # Skips rendering unless the required parameters are set
    def render?
      @parent_meeting.is_a?(GogglesDb::AbstractMeeting) && @event_type.is_a?(GogglesDb::EventType)
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
