# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7-0.6.30
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::LabelComponent
  #
  # => Suitable for *any* AbstractMeeting <=
  #
  # Renders the correct title of a Meeting (not a link).
  # Mainly used to abstract away the logic of the decorated title of any meeting
  # or workshop.
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
      decorated&.display_label&.html_safe # rubocop:disable Rails/OutputSafety
    end

    private

    # Returns the decorated base object instance, memoized.
    def decorated
      @decorated ||= @meeting&.decorate
    end
  end
end
