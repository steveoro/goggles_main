# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.05
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::TitleComponent
  #
  # Meeting label as dashboard title.
  # Renders also the "cancelled" stamp if @meeting.cancelled? is +true+.
  #
  # => Suitable for *any* AbstractMeeting <=
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
