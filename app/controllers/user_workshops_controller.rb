# frozen_string_literal: true

# = UserWorkshopsController
#
class UserWorkshopsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :prepare_managed_teams, only: [:show]

  # GET /user_workshops/:id
  # Shows "My attended Workshops" grid.
  # Selects all the workshops created or attended by the current user,
  # Requires authentication & a valid associated swimmer.
  #
  def index
    if current_user.swimmer.blank?
      flash[:warning] = I18n.t('home.my.errors.no_associated_swimmer')
      redirect_to(root_path) && return
    end

    @swimmer = current_user.swimmer
    @grid = UserWorkshopsGrid.new(grid_filter_params) do |scope|
      scope.where('(user_workshops.user_id = ?) OR (user_results.swimmer_id = ?)', current_user.id, @swimmer.id)
           .page(index_params[:page]).per(20)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # GET /user_workshops/for_swimmer/:id
  # Displays all attended Workshops for a swimmer using a grid.
  # Requires an existing swimmer.
  #
  # == Params
  # - :id => Swimmer ID, required
  def for_swimmer
    unless GogglesDb::Swimmer.exists?(id: user_workshop_params[:id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @swimmer = GogglesDb::Swimmer.find_by(id: user_workshop_params[:id])
    @grid = UserWorkshopsGrid.new(grid_filter_params) { |scope| scope.for_swimmer(@swimmer).page(index_params[:page]).per(20) }
  end

  # GET /user_workshops/for_team/:id
  # Displays all attended Workshops for a team using a grid.
  # Requires an existing team.
  #
  # == Params
  # - :id => Team ID, required
  def for_team
    unless GogglesDb::Team.exists?(id: user_workshop_params[:id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @team = GogglesDb::Team.find_by(id: user_workshop_params[:id])
    @grid = UserWorkshopsGrid.new(grid_filter_params) { |scope| scope.for_team(@team).page(index_params[:page]).per(20) }
  end
  #-- -------------------------------------------------------------------------
  #++

  # Show the details page
  # == Params
  # - :id => Workshop ID, required
  def show
    @user_workshop = GogglesDb::UserWorkshop.where(id: user_workshop_params[:id]).first
    if @user_workshop.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @managed_team_ids = @managed_teams.map(&:id) if @managed_teams.present?
    # Team managers of the Team that created this Workshop can act as Admins and manage any team in this:
    @managed_team_ids = nil if @managed_team_ids.is_a?(Array) && @managed_team_ids.include?(@user_workshop.team_id)

    @current_swimmer_id = current_user.swimmer_id if user_signed_in?
    @user_workshop_events = @user_workshop.event_types.uniq
    @user_workshop_results = @user_workshop.user_results.includes(:event_type)
  end
  #-- -------------------------------------------------------------------------
  #++

  protected

  # Strong parameters checking
  def user_workshop_params
    params.permit(:id, :page, :per_page)
  end

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Grid filtering strong parameters checking
  # (NOTE: member variable is needed by the view)
  def grid_filter_params
    @grid_filter_params = params.fetch(:user_workshops_grid, {})
                                .permit(:descending, :order, :workshop_date, :workshop_name)
    # Set default ordering for the datagrid:
    @grid_filter_params.merge(order: :workshop_date) unless @grid_filter_params.key?(:order)
    @grid_filter_params
  end
end
