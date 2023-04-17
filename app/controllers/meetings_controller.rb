# frozen_string_literal: true

# = MeetingsController
#
class MeetingsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :prepare_managed_teams, only: [:show, :team_results, :swimmer_results]

  before_action :validate_meeting, only: [:show, :team_results, :swimmer_results]
  before_action :validate_team, only: [:show, :team_results, :swimmer_results]
  before_action :validate_swimmer, only: [:index, :show, :team_results, :swimmer_results]

  # GET /meetings/:id
  # Shows "My attended Meetings" grid (just for the current user).
  # Requires authentication & a valid associated swimmer (or a :swimmer_id params override).
  #
  def index
    unless @swimmer
      flash[:warning] = I18n.t('home.my.errors.no_associated_swimmer')
      redirect_to(root_path) && return
    end

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

  # Show the result details page for a specific Team ID
  # == Params
  # - :id => Meeting ID, required
  def team_results
    if @meeting.nil? || @team.nil? # (min. requirements beside actual callbacks)
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @mir_list = @meeting.meeting_individual_results.for_team(@team)
                                                   .joins(:swimmer, :meeting_event, :event_type)
                                                   .includes(:swimmer, :meeting_event, :event_type)
    @mrr_list = @meeting.meeting_relay_results.for_team(@team)
    if @mir_list.empty? && @mrr_list.empty?
      flash[:error] = I18n.t('meetings.no_results_to_show')
      redirect_to(root_path) && return
    end

    # TODO ******************************************************************** WIP
    @meeting_team_swimmers = @mir_list.joins(:swimmer).includes(:swimmer)
      .group(:swimmer_id)
      .order('swimmers.complete_name ASC')
      .map{ |row| row.swimmer }
      .sort { |a, b| a.complete_name <=> b.complete_name }

    # Count top team rankings:
    @team_ranks = {}
    (1..4).to_a.each { |rank| @team_ranks[rank] = 0 }
    (1..4).to_a.each { |rank| @team_ranks[rank] += @mir_list.valid_for_ranking.for_rank(rank).count }

    # Count team highligths:
    @team_outstanding_scores = @mir_list.valid_for_ranking.where('standard_points > ?', 800).count

    #Map all events for each swimmer:
    meeting_team_swimmers_ids = @meeting_team_swimmers.collect{ |row| row.id }
    @events_per_swimmers = {}
    meeting_team_swimmers_ids.each do |id|
      @events_per_swimmers[ id ] = @mir_list.joins(:swimmer, meeting_event: [:event_type])
                                            .includes(:swimmer, meeting_event: [:event_type])
                                            .where(['meeting_individual_results.swimmer_id = ?', id])
    end

    ind_event_ids = @mir_list.map{ |row| row.meeting_event.id }.uniq
    rel_event_ids = @mrr_list.map{ |row| row.meeting_event.id }.uniq
    event_ids = (ind_event_ids + rel_event_ids).uniq.sort
    @team_tot_events = event_ids.size
    @meeting_events_list = GogglesDb::MeetingEvent.where(id: event_ids)
      .joins(:event_type, :stroke_type).includes(:event_type, :stroke_type)
      .order('event_types.relay, meeting_events.event_order')
    # Add to the stats the relay results:
    (1..4).to_a.each { |rank| @team_ranks[rank] += @mrr_list.valid_for_ranking.for_rank(rank).count }
    @team_outstanding_scores += @mrr_list.valid_for_ranking.where('standard_points > ?', 800).count

    # Get the programs filtered by team_id:
    ind_prg_ids = GogglesDb::MeetingIndividualResult.joins(:meeting, :meeting_program)
      .includes(:meeting, :meeting_program)
      .where(['meetings.id = ? AND meeting_individual_results.team_id = ?', @meeting.id, @team.id])
      .map{ |row| row.meeting_program_id }
      .uniq

    rel_prg_ids = GogglesDb::MeetingRelayResult.joins(:meeting, :meeting_program)
      .includes(:meeting, :meeting_program)
      .where(['meetings.id = ? AND meeting_relay_results.team_id = ?', @meeting.id, @team.id])
      .map{ |row| row.meeting_program_id }
      .uniq

    prg_ids = (ind_prg_ids + rel_prg_ids).uniq.sort
    @meeting_programs_list = GogglesDb::MeetingProgram.where( id: prg_ids )
      .joins(:event_type, :stroke_type)
      .includes(:event_type, :stroke_type)
      .order('event_types.relay, meeting_events.event_order')

    # Find out top scorer
    @top_scores = {}
    if @mir_list&.where('standard_points > 0')&.exists?
      @top_scores["#{GogglesDb::GenderType.male.code}-standard_points"] = @mir_list.for_gender_type(GogglesDb::GenderType.male).order(:standard_points).first
      @top_scores["#{GogglesDb::GenderType.female.code}-standard_points"] = @mir_list.for_gender_type(GogglesDb::GenderType.female).order(:standard_points).first
    end
    if @mir_list&.where('goggle_cup_points > 0')&.exists?
      @top_scores["goggle_cup_points"] = @mir_list.sort_by_goggle_cup.first
    end

    # Get a timestamp for the cache key:
    max_mir_updated_at = @mir_list.exists? ? @mir_list.select("meeting_individual_results.updated_at").order(:updated_at).last.updated_at.to_i : 0
    max_mrr_updated_at = @mrr_list.exists? ? @mrr_list.select("meeting_relay_results.updated_at").order(:updated_at).last.updated_at.to_i : 0
    @max_updated_at = max_mir_updated_at >= max_mrr_updated_at ? max_mir_updated_at : max_mrr_updated_at
  end
  #-- -------------------------------------------------------------------------
  #++

  # Show the result details page for a specific Swimmer ID
  # == Params
  # - :id => Meeting ID, required
  def swimmer_results
    if @meeting.nil? || @swimmer.nil? # (min. requirements beside actual callbacks)
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @mir_list = @meeting.meeting_individual_results.for_swimmer(@swimmer)
    if @mir_list.empty?
      flash[:error] = I18n.t('meetings.no_results_to_show')
      redirect_to(root_path) && return
    end

    # Get page timestamp as cache key:
    @max_updated_at = @mir_list.select( "meeting_individual_results.updated_at" )
                               .order(:updated_at).last
                               .updated_at.to_i
  end
  #-- -------------------------------------------------------------------------
  #++

  protected

  # /show, /team_results & /swimmer_results strong parameters checking
  def meeting_params
    params.permit(:id, :team_id, :swimmer_id, :page, :per_page)
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

  private

  # Prepares the internal @meeting variable according to params[:id]
  # Sets also @managed_team_ids assuming the :prepare_managed_teams callback has been run before.
  def validate_meeting
    @meeting = GogglesDb::Meeting.includes(:meeting_individual_results)
                                 .where(id: meeting_params[:id])
                                 .first
    @managed_team_ids = @managed_teams.map(&:id) if @managed_teams.present?
  end

  # Prepares the internal @team variable; falls backs to the first associated team found for the current swimmer if
  # available and not already filtered by :team_id.
  def validate_team
    @team = GogglesDb::Team.where(id: meeting_params[:team_id]).first
    @team = current_user.swimmer.associated_teams.first if user_signed_in? && @team.nil?
  end

  # Prepares the internal @swimmer & @current_swimmer_id variables
  # - <tt>@swimmer</tt> => filtered swimmer or defaults to current user's swimmer if none
  # - <tt>@current_swimmer_id</tt> => always referred to current user's swimmer (when available)
  def validate_swimmer
    @swimmer = GogglesDb::Swimmer.where(id: meeting_params[:swimmer_id]).first || current_user.swimmer
    @current_swimmer_id = current_user.swimmer_id if user_signed_in?
  end
end
