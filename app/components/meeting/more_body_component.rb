# frozen_string_literal: true

#
# = Meeting components module
#
#   - version:  7.05
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
  # => Suitable for *any* AbstractMeeting <=
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
      # Fallback to team_id for UserWorkshops / nils:
      @home_team = meeting.respond_to?(:home_team) ? meeting.home_team : meeting&.team
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting.class.ancestors.include?(GogglesDb::AbstractMeeting)
    end
  end
end
