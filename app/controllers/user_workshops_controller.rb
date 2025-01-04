# frozen_string_literal: true

# = UserWorkshopsController
#
class UserWorkshopsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :prepare_managed_teams, :validate_workshop, :validate_team,
                only: %i[show]
  before_action :validate_swimmer, only: %i[index show]

  # GET /user_workshops/:id
  # Shows "My attended Workshops" grid.
  # Selects all the workshops created or attended by the current user,
  # Requires authentication & a valid associated swimmer.
  #
  def index
    unless @swimmer
      flash[:warning] = I18n.t('home.my.errors.no_associated_swimmer')
      redirect_to(root_path) && return
    end

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
    if @user_workshop.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @user_workshop_events = @user_workshop.event_types.uniq
    @user_workshop_results = @user_workshop.user_results.includes(:event_type)

    # Get page timestamp for cache key:
    set_max_updated_at_for_workshop
  end
  #-- -------------------------------------------------------------------------
  #++

  protected

  # Strong parameters checking
  def user_workshop_params
    params.permit(:id, :team_id, :swimmer_id, :page, :per_page)
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

  private

  # Prepares the internal @user_workshop variable according to params[:id]
  def validate_workshop
    @user_workshop = GogglesDb::UserWorkshop.includes(:user_results, :event_types)
                                            .where(id: user_workshop_params[:id])
                                            .first
    return unless @user_workshop

    update_user_teams_for_seasons_ids([@user_workshop.season_id])
    update_managed_teams_for_seasons_ids([@user_workshop.season_id])
  end

  # Prepares the internal @team variable; falls backs to the first associated team found for the current swimmer if
  # available and not already filtered by :team_id.
  def validate_team # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    @team = GogglesDb::Team.where(id: user_workshop_params[:team_id]).first
    return unless user_signed_in? && current_user

    # See ApplicationController:88:112 (update_user_teams_for_seasons_ids)
    @team = @user_teams.last if @team.nil? && @user_teams.present?
    return if @team

    # Fallback to the first associated team found for the current user:
    @team = current_user.swimmer&.associated_teams&.first if @team.nil?
  end

  # Prepares the internal @swimmer & @current_swimmer_id variables
  # - <tt>@swimmer</tt> => filtered swimmer or defaults to current user's swimmer if none
  # - <tt>@current_swimmer_id</tt> => always referred to current user's swimmer (when available)
  def validate_swimmer
    @swimmer = GogglesDb::Swimmer.where(id: user_workshop_params[:swimmer_id]).first || current_user&.swimmer
    return unless user_signed_in?

    @current_swimmer_id = current_user.swimmer_id
  end
  #-- -------------------------------------------------------------------------
  #++

  # Sets the internal <tt>@max_updated_at</tt> value that will be used as main cache timestamp for the current <tt>@user_workshop</tt>.
  def set_max_updated_at_for_workshop
    # Get a timestamp from last updated result:
    @max_updated_at = @user_workshop.user_results.order('user_results.updated_at').last&.updated_at.to_i
  end
end
