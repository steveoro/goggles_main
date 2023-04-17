# frozen_string_literal: true

#
# = Title components module
#
#   - version:  7-0.5.01
#   - author:   Steve A.
#
module Title
  #
  # = Title::TeamShowLinkComponent
  #
  # Clickable "title" link for browsing back or to the specified action
  # usually associated with displaying the details of the entity (or any other
  # action filtered by the specific instance).
  #
  class TeamShowLinkComponent < ViewComponent::Base
    # Creates a new ViewComponent
    # This also wraps the destination action link with a proper tooltip using the row itself.
    #
    # == Params
    # - <tt>team</tt>: a valid Team instance
    #
    # - <tt>action_link_method</tt>: TeamDecorator helper symbol for the resulting action link;
    #                                defaults to <tt>link_to_full_name</tt>
    #
    # - <tt>link_extra_params</tt>: additional parameters for the <tt>action_link_method</tt>;
    #                               defaults to +nil+.
    def initialize(team:, action_link_method: :link_to_full_name, link_extra_params: nil)
      super
      @deco_team = TeamDecorator.decorate(team) if team
      @action_link_method = action_link_method
      @link_extra_params = link_extra_params
    end

    # Skips rendering unless the member is properly set
    def render?
      @deco_team.is_a?(GogglesDb::Team)
    end

    protected

    # Memoized link to the selected controller action; defaults to the /show action.
    def link_to_action
      return '?' if @deco_team.blank?

      @link_to_action ||= if @link_extra_params.present?
                            @deco_team.send(@action_link_method, @link_extra_params)
                          else
                            @deco_team.send(@action_link_method)
                          end
    end

    # Returns the proper tooltip key according to the specified @action_link_method;
    # Defaults to the tooltip for /teams/show/:id.
    def tooltip_key
      return 'meetings.tooltip.link.team_results' if @action_link_method == :link_to_results

      'teams.go_to_dashboard'
    end
  end
end
