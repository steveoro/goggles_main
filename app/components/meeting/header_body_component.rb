# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::HeaderBodyComponent
  #
  # Renders the Meeting main header details as a single +tbody+.
  #
  # Includes the trigger button to expand a sub-page of additional
  # collapsed details.
  #
  # === Known hack:
  # Wrap multiple +tbody+s inside another container +tbody+ for maximum
  # compatibility (i.e. 'header' tbody + 'more-details' tbody).
  #
  class HeaderBodyComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting: an undecorated GogglesDb::Meeting model instance
    # - subpage_target_id: the DOM ID for a collapsible sub-page of additional details
    def initialize(meeting:, subpage_target_id: 'more-details')
      super
      @meeting = meeting
      @subpage_target_id = subpage_target_id
      msession = meeting&.meeting_sessions&.by_order&.first
      @meeting_date = msession ? msession&.scheduled_date : meeting&.header_date
      @swimming_pool = msession ? SwimmingPoolDecorator.decorate(msession&.swimming_pool) : nil
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting.instance_of?(GogglesDb::Meeting)
    end
  end
end
