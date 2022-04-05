# frozen_string_literal: true

#
# = Title components module
#
#   - version:  7-0.3.50
#   - author:   Steve A.
#
module Title
  #
  # = Title::TeamShowLinkComponent
  #
  # Clickable "title" link for browsing back or to the "/show" action
  # associated with displaying the details of the entity.
  #
  class TeamShowLinkComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - team: a valid Team instance
    def initialize(team:)
      super
      @team = team
    end

    # Skips rendering unless the member is properly set
    def render?
      @team.is_a?(GogglesDb::Team)
    end

    protected

    # Memoized link to the /show action, if available
    def link_to_full_name
      return '?' if @team.blank?

      @link_to_full_name ||= TeamDecorator.decorate(@team).link_to_full_name
    end
  end
end
