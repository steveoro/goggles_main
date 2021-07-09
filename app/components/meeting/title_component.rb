# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.3.05
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::TitleComponent
  #
  # => Suitable for *any* AbstractMeeting <=
  #
  # Meeting label as dashboard title.
  # Renders also the "cancelled" stamp if @meeting.cancelled? is +true+.
  #
  class TitleComponent < ViewComponent::Base
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
  end
end
