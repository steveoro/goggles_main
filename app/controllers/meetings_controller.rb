# frozen_string_literal: true

# = MeetingsController
#
class MeetingsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  # GET /meetings/:id
  # Shows "My attended Meetings" grid (just for the current user).
  # Requires authentication & a valid associated swimmer.
  #
  def index
    if current_user.swimmer.blank?
      flash[:warning] = I18n.t('home.my.errors.no_associated_swimmer')
      redirect_to(root_path) && return
    end

    @swimmer = current_user.swimmer
    @grid = MeetingsGrid.new(grid_filter_params) { |scope| scope.for_swimmer(@swimmer).page(index_params[:page]).per(20) }
  end
  #-- -------------------------------------------------------------------------
  #++

  # GET /meetings/for_swimmer/:id
  # Displays all attended Meetings for any swimmer using a grid.
  # Requires an existing swimmer.
  #
  # == Params
  # - :id => Swimmer ID, required
  def for_swimmer
    unless GogglesDb::Swimmer.exists?(id: meeting_params[:id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @swimmer = GogglesDb::Swimmer.find_by(id: meeting_params[:id])
    @grid = MeetingsGrid.new(grid_filter_params) { |scope| scope.for_swimmer(@swimmer).page(index_params[:page]).per(20) }
  end

  # GET /meetings/for_team/:id
  # Displays all attended Meetings for a team using a grid.
  # Requires an existing team.
  #
  # == Params
  # - :id => Team ID, required
  def for_team
    unless GogglesDb::Team.exists?(id: meeting_params[:id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @team = GogglesDb::Team.find_by(id: meeting_params[:id])
    @grid = MeetingsGrid.new(grid_filter_params) { |scope| scope.for_team(@team).page(index_params[:page]).per(20) }
  end
  #-- -------------------------------------------------------------------------
  #++

  # Show the details page
  # == Params
  # - :id => Meeting ID, required
  def show
    @meeting = GogglesDb::Meeting.where(id: meeting_params[:id]).first
    if @meeting.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @managed_team_ids = managed_team_ids
    @current_swimmer_id = current_swimmer_id
    @meeting_events = @meeting.meeting_events
                              .includes(:meeting_session, :event_type, :stroke_type, season: [:season_type])
                              .joins(:meeting_session, :event_type, :stroke_type, season: [:season_type])
                              .unscope(:order)
                              .order('meeting_sessions.session_order, meeting_events.event_order')
  end
  #-- -------------------------------------------------------------------------
  #++

  protected

  # /show action strong parameters checking
  def meeting_params
    params.permit(:id, :page, :per_page)
  end

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Grid filtering strong parameters checking
  # (NOTE: member variable is needed by the view)
  def grid_filter_params
    @grid_filter_params = params.fetch(:meetings_grid, {})
                                .permit(:descending, :order, :meeting_date, :meeting_name)
    # Set default ordering for the datagrid:
    @grid_filter_params.merge(order: :meeting_date) unless @grid_filter_params.key?(:order)
    @grid_filter_params
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the list of unique managed team IDs for rendering the row action buttons every time
  # a MIR is assigned to a team_id in this list.
  #
  # Both "lap edit" & "report mistake" row buttons will be rendered if the check is successful.
  # The check will fail if the list is empty and it will be *totally skipped* if the list is +nil+.
  #
  # Returns an empty list if not signed in or if the user can't manage any team.
  # Returns +nil+ only if the current user is an Admin: this will disable ID checking for all rows,
  # rendering the "lap edit" button everywhere.
  #
  def managed_team_ids
    return [] unless user_signed_in?
    # Disable ID checking for all rows by returning nil on purpose:
    return if GogglesDb::GrantChecker.admin?(current_user)

    GogglesDb::ManagedAffiliation.includes(:team_affiliation)
                                 .where(user_id: current_user.id,
                                        'team_affiliations.season_id': parent_meeting.season_id)
                                 .map { |ma| ma.team_affiliation.team_id }
                                 .uniq
  end

  # Returns the current_user#swimmer_id, if any.
  def current_swimmer_id
    return unless user_signed_in?

    current_user.swimmer_id
  end
  #-- -------------------------------------------------------------------------
  #++
end
