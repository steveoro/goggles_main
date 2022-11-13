# frozen_string_literal: true

# = CalendarsController
#
class CalendarsController < ApplicationController
  before_action :authenticate_user!, :prepare_last_seasons,
                :prepare_user_teams, :prepare_managed_teams

  # GET /current
  # Prepares all the Calendar rows available for the latest seasons.
  # Requires authentication.
  #
  def current
    CalendarsGrid.managed_teams = @managed_teams
    @grid = CalendarsGrid.new(grid_filter_params) do |scope|
      scope.where(season_id: @last_seasons_ids).page(index_params[:page]).per(8)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # GET /starred
  # Prepares all the Calendar rows tagged as interesting either by the user or by the team.
  # Requires authentication.
  #
  def starred
    CalendarsGrid.managed_teams = @managed_teams
    @grid = CalendarsGrid.new(grid_filter_params) do |scope|
      scope.where(season_id: @last_seasons_ids, meeting_id: prepare_tagged_meeting_ids)
           .page(index_params[:page]).per(8)
    end
  end

  # GET /starred_map
  # Similar to /starred but prepares the meeting coordinates for map display instead
  # of building the CalendarsGrid.
  # Requires authentication.
  #
  def starred_map
    tagged_meeting_ids = prepare_tagged_meeting_ids

    @map_places = GogglesDb::Meeting.where(id: tagged_meeting_ids)
                                    .map do |meeting|
                                      extract_map_place_object(meeting)
                                    end
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Grid filtering strong parameters checking
  # (NOTE: member variable is needed by the view)
  def grid_filter_params
    @grid_filter_params = params.fetch(:calendars_grid, {})
                                .permit(:descending, :order, :meeting_name)
    # Set default ordering for the datagrid:
    @grid_filter_params.merge(order: :meeting_date) unless @grid_filter_params.key?(:order)
    @grid_filter_params
  end

  # Collects into an array all tagged Meeting IDs (both by current user & by the user's teams).
  # Uses @last_seasons_ids & @user_teams to filter out the tagged meetings.
  # Returns the array of unique tagged IDs.
  def prepare_tagged_meeting_ids
    tagged_meeting_ids = GogglesDb::Meeting.where(season_id: @last_seasons_ids)
                                           .tagged_with("u#{current_user.id}")
                                           .pluck(:id)
    # Add all other Meeting IDs that were tagged by a Team manager and to which the user is belonging to:
    @user_teams.each do |team|
      tagged_meeting_ids += GogglesDb::Meeting.where(season_id: @last_seasons_ids)
                                              .tagged_with("t#{team.id}")
                                              .pluck(:id)
    end
    tagged_meeting_ids.uniq!
    tagged_meeting_ids
  end

  # Returns the Hash object used by the map StimulusJS controller to display
  # coordinates for a place.
  #
  # == Params
  # - meeting: a valid GogglesDb::Meeting instance
  #
  # == Returns
  # An Hash having structure:
  #
  #      {
  #        lat:           <latitude_float_or_string>,    // required
  #        lng:           <longitude_float_or_string>,   // required
  #        name:          "place label or title HTML",   // required
  #        bold_text:     "additional place text rendered in bold",
  #        italic_text:   "additional place text rendered in italic"
  #        details_link1: "additional details HTML link #1",
  #        details_link2: "additional details HTML link #2",
  #        maps_url:      "external mapping service URL string"
  #      }
  #
  def extract_map_place_object(meeting)
    deco_meeting = MeetingDecorator.decorate(meeting)
    pool = deco_meeting.decorated.meeting_pool
    deco_pool = SwimmingPoolDecorator.decorate(pool) if pool
    {
      lat: deco_pool&.latitude,
      lng: deco_pool&.longitude,
      name: deco_meeting.link_to_full_name,
      bold_text: deco_meeting.decorated.scheduled_dates.join(', '),
      italic_text: deco_meeting.decorated.event_type_list.map(&:label).join(', '),
      details_link1: deco_pool&.link_to_full_name,
      # (details_link2 currently not used)
      maps_url: pool&.maps_uri
    }
  end
end
