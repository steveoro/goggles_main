# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Meeting
  #
  # = Meeting::MoreBodyComponent
  #
  # Collapsible table body (+tbody+) for additional Meeting details sub-page.
  #
  # - collapse DOM ID: 'more-details'
  #   (typically, to be triggered by an external component)
  #
  # === Known hack:
  # Wrap multiple +tbody+s inside another container +tbody+ for maximum
  # compatibility (i.e. 'header' tbody + 'more-details' tbody).
  #
  class MoreBodyComponent < ViewComponent::Base
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
      @meeting.instance_of?(GogglesDb::Meeting)
    end
  end
end
