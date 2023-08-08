# frozen_string_literal: true

#
# = Mevent components module
#
#   - version:  7-0.6.00
#   - author:   Steve A.
#
module Mevent
  #
  # = Mevent::RowTitleComponent
  #
  # Renders an EventType title as a sub-table row (+tr+).
  #
  # - DOM ID: "mevent-#{meeting_event.id}"
  #
  class RowTitleComponent < ViewComponent::Base
    # Creates a new ViewComponent showing the title of an event, possibly with
    # "report missing event" button, if the current user can manage this kind of reports.
    #
    # Safely works with both Meetings & UserWorkshops.
    #
    # == Params:
    # - event_container: an undecorated event container such as
    #   A) a GogglesDb::MeetingEvent instance => responds to :meeting & :event_type
    #   B: a GogglesDb::UserResult instance   => responds to :parent_meeting & :event_type
    #
    # - can_manage: when +true+ the row-action button "report missing" will be rendered; default: false
    #
    def initialize(event_container:, can_manage: false)
      super
      @event_container = event_container
      @can_manage = can_manage
    end

    # Skips rendering unless the member is properly set
    def render?
      @event_container.instance_of?(GogglesDb::MeetingEvent) ||
        @event_container.instance_of?(GogglesDb::UserResult)
    end

    protected

    # Returns the DOM ID for this component
    def dom_id
      "mevent-#{@event_container&.id}"
    end

    # Returns the parent Meeting of this event, if none
    def parent_meeting
      return @event_container.meeting_session.meeting if @event_container.respond_to?(:meeting_session)

      @event_container.parent_meeting
    end
  end
end
