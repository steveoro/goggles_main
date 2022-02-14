# frozen_string_literal: true

# = MeetingsController
#
class MeetingsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  # GET /meetings
  # Shows "My attended Meetings" grid.
  # Requires authentication & a valid associated swimmer.
  #
  def index
    if current_user.swimmer.blank?
      flash[:warning] = I18n.t('home.my.errors.no_associated_swimmer')
      redirect_to(root_path) && return
    end

    # FIXME: update [DB] gem for eager-loaded associations; current workaround:
    @swimmer = GogglesDb::Swimmer.includes(:gender_type).find_by(id: current_user.swimmer_id) if current_user.swimmer
    @grid = MeetingsGrid.new(grid_params) do |scope|
      scope.where('meeting_individual_results.swimmer_id': @swimmer.id)
           .page(index_params[:page]).per(20)
    end
  end

  # Show the details page
  # == Params
  # - :id, required
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

  protected

  # /show action strong parameters checking
  def meeting_params
    params.permit(:id)
  end

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Grid filtering strong parameters checking
  def grid_params
    params.fetch(:meetings_grid, {})
          .permit(:descending, :order, :meeting_date, :meeting_name)
  end
end
