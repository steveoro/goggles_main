# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.05
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
  # => Suitable for *any* AbstractMeeting <=
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
      @meeting_date = choose_abstract_meeting_date(meeting)
      @swimming_pool = choose_abstract_meeting_pool(meeting)
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting.class.ancestors.include?(GogglesDb::AbstractMeeting)
    end

    private

    # Sets the @meeting_date member
    def choose_abstract_meeting_date(meeting)
      if meeting.respond_to?(:meeting_sessions)
        msession = meeting&.meeting_sessions&.by_order&.first
        msession&.scheduled_date

      elsif meeting.respond_to?(:header_date)
        meeting&.header_date
      end
    end

    # Sets the @swimming_pool member
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def choose_abstract_meeting_pool(meeting)
      if meeting.respond_to?(:meeting_sessions)
        msession = meeting&.meeting_sessions&.by_order&.first
        SwimmingPoolDecorator.decorate(msession&.swimming_pool)

      elsif meeting.respond_to?(:swimming_pool) && meeting.swimming_pool
        SwimmingPoolDecorator.decorate(meeting.swimming_pool)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
