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
end
