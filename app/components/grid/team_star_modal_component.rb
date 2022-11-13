# frozen_string_literal: true

#
# = Grid components module
#
#   - version:  7-0.4.21
#   - author:   Steve A.
#
module Grid
  #
  # = Grid::TeamStarModalComponent
  #
  # Renders the Team tag/star modal dialog for tagging a specific Meeting row ID as "team starred"
  # by selecting a specific Team (ID) from the available list of affiliation for the current user,
  # presumably filtered by the last available season(s) ID(s).
  #
  # The modal is rendered as 'asset free' and it needs the Grid::TeamStarButton component
  # to set the hidden <tt>meeting_id</tt> value for the POST action and to show this modal.
  #
  class TeamStarModalComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>:current_user</tt>
    #  valid User model instance to which this component will be linked to (*required*)
    #
    # - <tt>:user_teams</tt>
    #  list of selectable Teams for the current user, either managed-by or just belonging-to (*required*)
    #
    def initialize(current_user:, user_teams:)
      super
      @current_user = current_user
      @user_teams = user_teams.presence || []
    end

    # Skips rendering unless the minimum required parameters are set
    def render?
      @current_user.is_a?(GogglesDb::User) && @current_user.id.to_i.positive?
    end
  end
end
