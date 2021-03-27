# frozen_string_literal: true

#
# = Mevent components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Mevent
  #
  # = Mevent::RowTitleComponent
  #
  # Renders the MeetingEvent title as sub-table row (+tr+).
  #
  # - DOM ID: "mevent-#{meeting_event.id}"
  #
  class RowTitleComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting_event: an undecorated GogglesDb::MeetingEvent model instance
    def initialize(meeting_event:)
      super
      @meeting_event = meeting_event
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting_event.instance_of?(GogglesDb::MeetingEvent)
    end

    protected

    # Returns the DOM ID for this component
    def dom_id
      "mevent-#{@meeting_event&.id}"
    end
  end
end
