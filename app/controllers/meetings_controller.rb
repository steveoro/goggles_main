# frozen_string_literal: true

# = MeetingsController
#
class MeetingsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :prepare_user_teams, :prepare_managed_teams, :validate_meeting, :validate_team,
                only: %i[show team_results swimmer_results]
  before_action :validate_swimmer, except: %i[for_swimmer for_team]

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
                              .order('meeting_sessions.session_order, meeting_events.event_order')
    # Get page timestamp for cache key:
    set_max_updated_at_for_meeting
    check_default_team_or_swimmer_in_meeting
  end

  # GET [XHR] - Renders just a single MeetingEvent section via AJAX call
  #
  # == Required params:
  # - id: the MeetingEvent related to the meeting results section to be rendered
  #
  # rubocop:disable Metrics/AbcSize
  def show_event_section
    unless request.xhr? && GogglesDb::MeetingEvent.exists?(meeting_params[:id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @meeting_event = GogglesDb::MeetingEvent.find(meeting_params[:id])
    @meeting_events = @meeting_event.meeting.meeting_events.by_order.to_a
    @event_index = @meeting_events.find_index(@meeting_event)
    @prgs_for_event = GogglesDb::MeetingProgram.where(meeting_event_id: meeting_params[:id])
                                               .includes(:meeting, :gender_type, :category_type, :season, :meeting_individual_results)
                                               .joins(:gender_type, :category_type, :season)
                                               .order('category_types.age_begin, gender_types.id DESC')
    update_user_teams_for_seasons_ids([@meeting_event.season.id])
    update_managed_teams_for_seasons_ids([@meeting_event.season.id])
  end
  # rubocop:enable Metrics/AbcSize
  #-- -------------------------------------------------------------------------
  #++

  # Show the result details page for a specific Team ID
  # == Params
  # - :id => Meeting ID, required
  #
  # rubocop:disable Metrics/AbcSize
  def team_results
    if @meeting.nil? || @team.nil? # (min. requirements beside actual callbacks)
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @mir_list = collect_team_mirs(@meeting, @team)
    @mrr_list = collect_team_mrrs(@meeting, @team)
    if @mir_list.empty? && @mrr_list.empty?
      flash[:warning] = I18n.t('meetings.no_results_to_show_for_team', team: @team.editable_name)
      redirect_to(meeting_show_path(@meeting)) && return
    end

    @meeting_team_swimmers = map_team_swimmers_from(@mir_list)
    @team_ranks = map_team_ranks_from(@mir_list)
    @events_per_swimmers = map_events_per_swimmers_from(@meeting_team_swimmers, @mir_list)
    # Count outstanding scores:
    @team_outstanding_scores = @mir_list.valid_for_ranking.where('standard_points > ?', 800).count

    event_ids = map_tot_team_event_ids_from(@mir_list, @mrr_list)
    @team_tot_events = event_ids.size

    # Add to the stats the relay results:
    (1..4).to_a.each { |rank| @team_ranks[rank] += @mrr_list.valid_for_ranking.for_rank(rank).count }
    @team_outstanding_scores += @mrr_list.valid_for_ranking.where('standard_points > ?', 800).count

    @meeting_events_list = GogglesDb::MeetingEvent.where(id: event_ids).order('event_types.relay, meeting_events.event_order')

    # Get the programs filtered by team_id:
    prg_ids = map_tot_team_program_ids_from(@meeting, @team)
    @meeting_programs_list = GogglesDb::MeetingProgram.where(id: prg_ids).order('event_types.relay, meeting_events.event_order')

    # Find out top scorers for this meetings & custom cups:
    @top_scores = map_top_scores_from(@mir_list)

    # Get page timestamp for cache key:
    set_max_updated_at_for_meeting
    check_default_team_or_swimmer_in_meeting
  end
  # rubocop:enable Metrics/AbcSize
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
      flash[:warning] = I18n.t('meetings.no_results_to_show_for_swimmer', swimmer: @swimmer.complete_name)
      redirect_to(meeting_show_path(@meeting)) && return
    end

    # Get page timestamp for cache key:
    set_max_updated_at_for_meeting
    check_default_team_or_swimmer_in_meeting
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
  def validate_meeting
    @meeting = GogglesDb::Meeting.where(id: meeting_params[:id]).first
    return unless @meeting

    update_user_teams_for_seasons_ids([@meeting.season_id])
    update_managed_teams_for_seasons_ids([@meeting.season_id])
  end

  # Prepares the internal @team variable; falls backs to the first associated team found for the current swimmer if
  # available and not already filtered by :team_id.
  def validate_team # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    @team = GogglesDb::Team.where(id: meeting_params[:team_id]).first
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
    @swimmer = GogglesDb::Swimmer.where(id: meeting_params[:swimmer_id]).first || current_user&.swimmer
    return unless user_signed_in?

    @current_swimmer_id = current_user.swimmer_id
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the query selecting all swimmers enrolled by the current team using the prefiltered <tt>mir_list</tt>
  # relation, ordered by swimmer name.
  #
  # == Params:
  # - <tt>mir_list</tt>: the MIR list for the current meeting involving the current team.
  def map_team_swimmers_from(mir_list)
    mir_list.group(:swimmer_id)
            .order('swimmers.complete_name ASC')
            .map(&:swimmer)
            .sort_by(&:complete_name)
  end

  # Counts all top ranks reached by the current team.
  # Returns an Hash keyed by result rank (1..4) that maps the count of the corresponding result position
  # for of all team results.
  #
  # == Params:
  # - <tt>mir_list</tt>: the MIR list for the current meeting involving the current team.
  #
  # == Returns:
  # An Hash keyed by ranking position (1..4) mapping the count of those positions reached by the current team.
  def map_team_ranks_from(mir_list)
    # Count top team rankings:
    team_ranks = {}
    (1..4).to_a.each { |rank| team_ranks[rank] = team_ranks[rank].to_i + mir_list.valid_for_ranking.for_rank(rank).count }
    team_ranks
  end

  # Maps all events for each team swimmer.
  # Returns an Hash keyed by swimmer ID that maps the relation filtering all events involving each swimmer
  # of the current team.
  #
  # == Params:
  # - <tt>meeting_team_swimmers</tt>: the list of all swimmers involved in the current meeting by the current team.
  # - <tt>mir_list</tt>: the MIR list for the current meeting involving the current team.
  #
  # == Returns:
  # An Hash of meeting events keyed by swimmer ID.
  def map_events_per_swimmers_from(meeting_team_swimmers, mir_list)
    meeting_team_swimmers_ids = meeting_team_swimmers.collect(&:id)
    events_per_swimmers = {}
    meeting_team_swimmers_ids.each do |id|
      events_per_swimmers[id] = mir_list.where(meeting_individual_results: { swimmer_id: id })
    end
    events_per_swimmers
  end

  # Maps all meeting event IDs for the current team from all possible results (both individuals & relays).
  #
  # == Params:
  # - <tt>mir_list</tt>: the MIR list for the current meeting involving the current team.
  # - <tt>mrr_list</tt>: the MRR list for the current meeting involving the current team.
  #
  # == Returns:
  # An array sorted by ID.
  def map_tot_team_event_ids_from(mir_list, mrr_list)
    ind_event_ids = mir_list.distinct('meeting_events.id').pluck('meeting_events.id')
    rel_event_ids = mrr_list.distinct('meeting_events.id').pluck('meeting_events.id')
    (ind_event_ids + rel_event_ids).uniq.sort
  end

  # Maps all meeting program IDs for the current team & meeting.
  #
  # == Params:
  # - <tt>meeting</tt>: the current Meeting.
  # - <tt>team</tt>: the current Team.
  #
  # == Returns:
  # An array sorted by ID.
  def map_tot_team_program_ids_from(meeting, team)
    ind_prg_ids = GogglesDb::MeetingIndividualResult.where(['meetings.id = ? AND meeting_individual_results.team_id = ?', meeting.id, team.id])
                                                    .pluck(:meeting_program_id)
                                                    .uniq

    rel_prg_ids = GogglesDb::MeetingRelayResult.where(['meetings.id = ? AND meeting_relay_results.team_id = ?', meeting.id, team.id])
                                               .pluck(:meeting_program_id)
                                               .uniq
    (ind_prg_ids + rel_prg_ids).uniq.sort
  end

  # Collects and returns all the MIR rows from the specified Meeting & Team tuple.
  def collect_team_mirs(meeting, team)
    meeting.meeting_individual_results.includes(meeting_program: [meeting_event: :event_type]).for_team(team)
  end

  # Collects and returns all the MRR rows from the specified Meeting & Team tuple.
  def collect_team_mrrs(meeting, team)
    meeting.meeting_relay_results.includes(meeting_program: [meeting_event: :event_type]).for_team(team)
  end

  # Maps the top scores for each gender & custom (Goggle-) cup.
  #
  # == Params:
  # - <tt>mir_list</tt>: the MIR list for the current meeting involving the current team.
  #
  # == Returns:
  # An Hash mapping 3 MIRs and keyed with:
  # - 'M-std' => male standard points
  # - 'F-std' => female standard points
  # - 'gogglecup' => absolute points for the custom cup of the team
  def map_top_scores_from(mir_list)
    top_scores = {}
    if mir_list&.where('standard_points > 0')&.exists?
      # NOTE: somehow ".order(standard_points: :desc).first" doesn't work 2 times in a row here after the upgrade to Rails 6.1:
      top_scores["#{GogglesDb::GenderType.male.code}-std"] = mir_list.for_gender_type(GogglesDb::GenderType.male)
                                                                     .max_by(&:standard_points)
      top_scores["#{GogglesDb::GenderType.female.code}-std"] = mir_list.for_gender_type(GogglesDb::GenderType.female)
                                                                       .max_by(&:standard_points)
    end
    if mir_list&.where('goggle_cup_points > 0')&.exists?
      # (GoggleCups are absolute in category & gender free)
      # XXX TODO: MIR.by_goggle_cup()
      top_scores['gogglecup'] = mir_list.where('goggle_cup_points > 0').order(:goggle_cup_points).last
    end
    top_scores
  end
  #-- -------------------------------------------------------------------------
  #++

  # Sets <tt>@default_team_or_swimmer_in_meeting</tt> to +true+ only if the default current swimmer & team
  # are present in the current @meeting.
  # Use to enable or not certain meeting nav tabs.
  #
  # Can be called only after:
  # 1. ApplicationController#prepare_user_teams
  # 2. this#validate_meeting
  # 3. this#validate_swimmer
  #
  def check_default_team_or_swimmer_in_meeting
    # True whenever we can switch to the result tabs without having a filtering parameter:
    @default_team_or_swimmer_in_meeting = GogglesDb::Meeting.includes(meeting_individual_results: %i[swimmer team])
                                                            .joins(meeting_individual_results: %i[swimmer team])
                                                            .exists?(
                                                              id: @meeting.id,
                                                              'teams.id': @user_teams.map(&:id),
                                                              'swimmers.id': @current_swimmer_id
                                                            )
  end

  # Sets the internal <tt>@max_updated_at</tt> value that will be used as main cache timestamp for the current <tt>@meeting</tt>.
  def set_max_updated_at_for_meeting
    # Get a timestamp from last updated result:
    max_mir_updated_at = @meeting.meeting_individual_results.order(:updated_at).last&.updated_at.to_i
    max_mrr_updated_at = @meeting.meeting_relay_results.order(:updated_at).last&.updated_at.to_i
    @max_updated_at = [max_mir_updated_at, max_mrr_updated_at].max
  end
end
