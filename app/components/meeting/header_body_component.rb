# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7-0.7.24
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::HeaderBodyComponent
  #
  # => Suitable for *any* AbstractMeeting <=
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
      return if @meeting.blank?

      @meeting_date = choose_abstract_meeting_date(meeting)
      @swimming_pool = choose_abstract_meeting_pool(meeting)
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting.present? && @meeting.class.ancestors.include?(GogglesDb::AbstractMeeting)
    end

    private

    # Sets the @meeting_date member
    def choose_abstract_meeting_date(meeting)
      meeting.decorate.meeting_date
    end

    # Sets the @swimming_pool member
    def choose_abstract_meeting_pool(meeting)
      pool = meeting.decorate.meeting_pool
      return if pool.blank?

      SwimmingPoolDecorator.decorate(pool)
    end
  end
end
