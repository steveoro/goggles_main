# frozen_string_literal: true

# = BadgesController
#
class BadgesController < ApplicationController
  before_action :authenticate_user!
  before_action :prepare_team

  # GET /badges
  # Shows "all the swimmers for a team" grid.
  # Selects all the badges associated to the specified team & season.
  # Requires authentication.
  #
  # == Params
  # - :id => *Team* ID, required; the team id will be stored in the cookies and updated each time.
  #
  def index
    unless @team
      flash[:warning] = I18n.t('teams.errors.no_team')
      redirect_to(home_dashboard_path) && return
    end

    @grid = BadgesGrid.new(grid_params) do |scope|
      scope.for_team(@team)
           .page(index_params[:page]).per(20)
    end
  end

  protected

  # /show action strong parameters checking
  def badge_params
    params.permit(:id)
  end

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Grid filtering strong parameters checking
  def grid_params
    params.fetch(:badges_grid, {})
          .permit(:descending, :order, :name, :season)
  end

  private

  # Setter for the @team member variable either based on params or cookies.
  # Updates the cookies with the new value.
  def prepare_team
    @team = GogglesDb::Team.find_by(id: badge_params[:id])
    @team ||= GogglesDb::Team.find_by(id: cookies[:team_id]) if cookies[:team_id].present?
    cookies[:team_id] = @team.id if @team.present?
  end
end
