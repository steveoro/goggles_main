# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.3.05
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::LabelComponent
  #
  # => Suitable for *any* AbstractMeeting <=
  #
  # Renders the correct title of a Meeting
  #
  class LabelComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting: an undecorated GogglesDb::Meeting model instance
    def initialize(meeting:)
      super
      @meeting = meeting
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting.class.ancestors.include?(GogglesDb::AbstractMeeting)
    end

    # Inline rendering
    def call
      meeting_label
    end

    protected

    # Prepares the text label
    def meeting_label
      if @meeting&.edition_type&.seasonal? || @meeting&.edition_type&.yearly?
        edition_title_text
      else
        default_title_text
      end
    end

    # Memoized default title text for generic meetings
    def default_title_text
      @default_title_text ||= "#{@meeting&.edition_label} #{@meeting&.description}"
    end

    # Memoized title text for seasonal/yearly meetings
    def edition_title_text
      @edition_title_text ||= "#{@meeting&.description} #{@meeting&.edition_label}"
    end
  end
end
