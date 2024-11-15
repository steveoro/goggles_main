# frozen_string_literal: true

#
# = Mevent components module
#
#   - version:  7-0.6.24
#   - author:   Steve A.
#
module Mevent
  #
  # = Mevent::RowLinksComponent
  #
  # Renders a sequence of links to all the MeetingEvents enlisted
  # in the specified association parameter.
  #
  # MeetingEvents are supposed to be *already* sorted by order.
  #
  # Includes a link to the top of page ('#top-of-page').
  #
  # - linked DOM IDs: "mevent-#{meeting_event.id}"
  #
  class RowLinksComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting_events: an undecorated GogglesDb::MeetingEvent association or an Array
    def initialize(meeting_events:)
      super
      @meeting_events = meeting_events
    end

    # Skips rendering unless @meeting_events is enumerable and orderable :by_order
    def render?
      @meeting_events.respond_to?(:each)
    end
  end
end
