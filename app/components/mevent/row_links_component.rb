# frozen_string_literal: true

#
# = Mevent components module
#
#   - version:  7-0.6.00
#   - author:   Steve A.
#
module Mevent
  #
  # = Mevent::RowLinksComponent
  #
  # Renders a sequence of links to all the MeetingEvents enlisted
  # in the specified association parameter.
  #
  # Includes a link to the top of page ('#top-of-page').
  #
  # - linked DOM IDs: "mevent-#{meeting_event.id}"
  #
  class RowLinksComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting_events: an undecorated GogglesDb::MeetingEvent association
    def initialize(meeting_events:)
      super
      @meeting_events = meeting_events
    end

    # Skips rendering unless @meeting_events is enumerable and orderable :by_order
    def render?
      @meeting_events.respond_to?(:each) && @meeting_events.respond_to?(:by_order)
    end
  end
end
