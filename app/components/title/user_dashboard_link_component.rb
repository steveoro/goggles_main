# frozen_string_literal: true

#
# = Title components module
#
#   - version:  7-0.3.50
#   - author:   Steve A.
#
module Title
  #
  # = Title::UserDashboardLinkComponent
  #
  # Clickable "title" link for browsing back or to the "/show" action
  # associated with displaying the details or the dashboard of the entity.
  #
  class UserDashboardLinkComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - user: a valid User instance
    def initialize(user:)
      super
      @user = user
    end

    # Skips rendering unless the member is properly set
    def render?
      @user.is_a?(GogglesDb::User)
    end

    protected

    # Memoized link to the /dashboard action, if available
    def link_to_full_name
      return '?' if @user.blank?

      @link_to_full_name ||= if @user.swimmer.present?
                               swimmer = GogglesDb::Swimmer.includes(:gender_type)
                                                           .find_by(id: @user.swimmer_id)
                               link_to(swimmer.decorate.display_label, home_dashboard_path)
                             else
                               link_to(@user.description, home_dashboard_path)
                             end
    end
  end
end
