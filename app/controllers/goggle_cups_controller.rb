# frozen_string_literal: true

# = GoggleCupsController
#
# Goggle Cup management for team managers and admins, plus read-only browsing
# of the stored rankings.
#
# Selection chain (mirrors goggles_admin2's GogglesCup page):
# championship year -> primary team (readonly when the user manages a single
# team for the year) -> existing cup or a new one -> rules card (name,
# description, end_date, no_duplicated_events, publish toggle) -> swimmer
# selection -> stored/computed ranking + export buttons.
#
# Reads are local (engine models + deserialized ranking_data); all mutations
# (save/compute/clear_ranking/publish/unpublish) are proxied to goggles_api's
# GoggleCupManageAPI with a per-request JWT, so the remote DB stays the single
# source of truth (and badges are provisioned there).
#
# Create/edit/publish are allowed only for the current MASFIN championship
# year: past cups stay browsable but read-only (editing them requires admin2).
#
# rubocop:disable Metrics/ClassLength
class GoggleCupsController < ApplicationController
  helper_method :user_is_admin?
  before_action :authenticate_user!
  before_action :validate_manager_or_admin!
  before_action :set_goggle_cup, except: %i[smart_selection]
  before_action :set_season_year
  before_action :set_team, except: %i[clear_ranking publish unpublish]
  before_action :set_team_from_cup, only: %i[clear_ranking publish unpublish]
  before_action :set_secondary_team, only: %i[index]
  before_action :set_no_duplicated_events, only: %i[compute]
  before_action :check_editable_year!, only: %i[save compute clear_ranking publish unpublish]
  around_action :with_base_year, only: %i[index ranking smart_selection]

  # Actions writing data remotely: allowed only for teams managed in the
  # current championship year (browsing accepts any managed season).
  MUTATION_ACTIONS = %w[save compute clear_ranking publish unpublish].freeze
  RANKING_EXPORT_FORMATS = %i[csv xlsx pdf].freeze

  # [GET] Renders the GoggleCup selection/configuration page.
  def index
    prepare_page_context
  end

  # [GET] Returns smart-selected swimmer ids for the secondary team filter.
  def smart_selection
    selected_ids = @team ? swimmer_options_query.smart_selected_ids_for(params[:secondary_team_id]) : []

    render json: { swimmer_ids: selected_ids }
  end

  # [POST] Creates or updates the cup configuration remotely via the manage API.
  def save
    result = goggle_cup_api_request(@goggle_cup ? :put : :post,
                                    @goggle_cup ? "/#{@goggle_cup.id}" : '',
                                    save_payload)
    if result[:error]
      redirect_to(goggle_cups_path(back_params),
                  alert: t('goggle_cups.cup_save_error', errors: result[:error])) && return
    end

    new_cup_id = result.dig(:json, 'cup', 'id') || @goggle_cup&.id
    redirect_to(goggle_cups_path(back_params(goggle_cup_id: new_cup_id)),
                notice: t('goggle_cups.cup_saved'))
  end

  # [POST] Computes the ranking on the remote API (persisted to
  # ranking_data) and renders the ranking panel via AJAX/redirect.
  def compute
    return respond_with_alert(t('goggle_cups.errors.save_first')) if @goggle_cup.blank?

    result = goggle_cup_api_request(
      :post, "/#{@goggle_cup.id}/compute",
      swimmer_ids: Array(params[:swimmer_ids]).compact_blank.map(&:to_i),
      no_duplicated_events: @no_duplicated_events == true
    )

    return respond_with_alert(t('goggle_cups.cup_save_error', errors: result[:error])) if result[:error]

    respond_to do |format|
      format.json do
        # The remote compute persisted the new ranking_data: reload and
        # deserialize locally so the partial gets the engine-shaped entries.
        @ranking_data = deserialized_ranking(@goggle_cup.reload)
        render json: { html: ranking_html(@ranking_data) }
      end
      format.html { redirect_to(goggle_cup_ranking_path(@goggle_cup)) }
    end
  end

  # [POST] Clears the stored ranking so the swimmer selection becomes editable.
  def clear_ranking
    return respond_with_alert(t('goggle_cups.cup_not_found')) if @goggle_cup.blank?

    result = goggle_cup_api_request(:post, "/#{@goggle_cup.id}/clear_ranking")
    redirect_after_mutation(result, t('goggle_cups.ranking_cleared'))
  end

  # [POST] Marks the cup as the single published cup for its affiliation.
  def publish
    return respond_with_alert(t('goggle_cups.cup_not_found')) if @goggle_cup.blank?

    result = goggle_cup_api_request(:post, "/#{@goggle_cup.id}/publish")
    redirect_after_mutation(result, t('goggle_cups.published_ok'))
  end

  # [POST] Clears the published flag.
  def unpublish
    return respond_with_alert(t('goggle_cups.cup_not_found')) if @goggle_cup.blank?

    result = goggle_cup_api_request(:post, "/#{@goggle_cup.id}/unpublish")
    redirect_after_mutation(result, t('goggle_cups.unpublished_ok'))
  end

  # [GET] Streams the stored ranking for the selected cup.
  # Exports (CSV/XLSX/PDF) skip the page context and use only the stored
  # ranking (no zero-points roster fallback).
  def ranking
    return respond_with_alert(t('goggle_cups.cup_not_found')) if @goggle_cup.blank?
    return send_ranking_export(format: request.format.symbol) if RANKING_EXPORT_FORMATS.include?(request.format.symbol)

    @ranking_visible = true
    prepare_page_context
    return respond_with_alert(t('goggle_cups.info.no_ranking_data')) if @ranking_data.blank?

    respond_to do |format|
      format.turbo_stream
      format.html { render(:index) }
    end
  end

  # [GET] Renders the base timings for the selected cup.
  def base_timings
    return respond_with_alert(t('goggle_cups.cup_not_found')) if @goggle_cup.blank?
    return respond_with_alert(t('goggle_cups.info.no_ranking_data')) if @goggle_cup.ranking_data.blank?

    @selected_team = @goggle_cup.team
    @ranking_data = GogglesDb::GoggleCupRanking::DataDeserializer.new(@goggle_cup).call
    @no_duplicated_events = no_duplicated_events_from(@goggle_cup)

    respond_to do |format|
      format.html { render(:base_timings) }
    end
  end

  private

  def validate_manager_or_admin!
    return if user_is_admin? || managed_team_ids_for_user.present?

    respond_with_alert(t('goggle_cups.unauthorized'), root_path)
  end

  # Sets @goggle_cup from :goggle_cup_id (selection chain) or :id (REST-ish
  # actions). The cup, when present, is authoritative for team & season year.
  def set_goggle_cup
    cup_id = params[:goggle_cup_id].presence || params[:id].presence
    @goggle_cup = GogglesDb::GoggleCup.find_by(id: cup_id) if cup_id.present?
  end

  # Sets @season_year: the selected cup's year, the explicit parameter, or the
  # current MASFIN championship year as fallback.
  def set_season_year
    @season_year = @goggle_cup&.season_year ||
                   params[:season_year].presence&.to_i ||
                   current_championship_year
  end

  def current_championship_year
    @current_championship_year ||= GogglesDb::Season.current_championship_year(GogglesDb::SeasonType.mas_fin)
  end

  # Sets @team: the cup's team, the explicit :team_id parameter, or (on index)
  # the default team resolved for the current user. For the cup-scoped mutation
  # actions (publish/unpublish/clear_ranking) the cup's team is authoritative.
  def set_team
    @team = @goggle_cup&.team || selected_or_default_team

    if unmanaged_team_requested?
      @team = nil
      return respond_with_alert(t('goggle_cups.unauthorized_team'))
    end

    @team_id = @team&.id || params[:team_id]
  end

  # On index, a manager's :team_id param is honored only for teams managed on
  # the shown championship year (the year select auto-submits the whole form,
  # so a stale param must not shadow the resolver's default); otherwise the
  # default resolved for the year wins. Other actions and admins keep the
  # param as-is.
  def selected_or_default_team
    requested = requested_team
    return requested if action_name != 'index' || user_is_admin?
    return requested if requested.present? && !stale_team_selection?(requested)

    team_resolver.default_team
  end

  def requested_team
    GogglesDb::Team.find_by(id: params[:team_id]) if params[:team_id].present?
  end

  # True when the requested team is managed by the user but not on the shown
  # championship year (stale param carried over by the year auto-submit).
  def stale_team_selection?(team)
    managed_team_ids_for_user.include?(team.id) && team_resolver.managed_team_ids.exclude?(team.id)
  end

  # Non-admin managers can only pick teams they manage: in any season for
  # browsing, in the current championship year for mutations.
  def unmanaged_team_requested?
    return false if @team.blank? || user_is_admin?

    allowed_ids = MUTATION_ACTIONS.include?(action_name) ? current_year_managed_team_ids : managed_team_ids_for_user
    allowed_ids.exclude?(@team.id)
  end

  def current_year_managed_team_ids
    @current_year_managed_team_ids ||= GogglesDb::GogglesCup::ManagedTeamResolver.new(
      user: current_user, season_year: current_championship_year, restrict_to_shown_season: true
    ).managed_team_ids
  end

  # Sets @team for actions not covered by set_team, from the loaded cup.
  def set_team_from_cup
    @team = @goggle_cup&.team
    return respond_with_alert(t('goggle_cups.unauthorized_team')) if unmanaged_team_requested?

    @team_id = @team&.id || params[:team_id]
  end

  def team_resolver
    @team_resolver ||= GogglesDb::GogglesCup::ManagedTeamResolver.new(
      user: current_user, season_year: @season_year || current_championship_year,
      restrict_to_shown_season: true
    )
  end

  def set_secondary_team
    @secondary_team_id = params[:secondary_team_id]
    @secondary_team = GogglesDb::Team.find_by(id: @secondary_team_id) if @secondary_team_id.present?
  end

  # Mutations are restricted to the current championship year; past cups are
  # read-only on main (admin2 edits them).
  def check_editable_year!
    year = @goggle_cup&.season_year || @season_year
    return if year.to_i == current_championship_year

    respond_with_alert(t('goggle_cups.errors.not_editable_year'), goggle_cups_path)
  end

  # Sets the +@base_year+ session variable used by the parameterized Scenic
  # views to the championship year being displayed, then always resets it.
  def with_base_year
    GogglesDb::AbstractBestResult.with_base_year(@season_year || current_championship_year)
    yield
  ensure
    GogglesDb::AbstractBestResult.with_base_year(nil)
  end

  # Prepares all shared ivars used by the index view.
  def prepare_page_context
    @team_resolver = team_resolver
    @managed_teams = @team_resolver.managed_teams
    @season_years = available_years
    @goggle_cups = @team ? goggle_cups_for_selection : []
    @editable = @season_year.to_i == current_championship_year
    @readonly = @goggle_cup&.ranking_data.present?
    @no_duplicated_events = no_duplicated_events_from(@goggle_cup)
    prepare_swimmer_context
    prepare_ranking_context
  end

  def prepare_swimmer_context
    @swimmers_for_team = @team ? swimmer_options_query.call : []
    @external_swimmers = external_swimmers_for(@goggle_cup)
    @selected_swimmer_ids = @goggle_cup&.swimmer_ids_array&.map(&:to_s) || []
  end

  def prepare_ranking_context
    @ranking_data = @goggle_cup ? deserialized_ranking(@goggle_cup) : []
    @ranking_visible = false if @ranking_visible.nil?
  end

  # Deserializes stored ranking_data, falling back to a zero-point alphabetical
  # roster when the cup has enlisted swimmers but no computed ranking yet.
  def deserialized_ranking(cup)
    GogglesDb::GoggleCupRanking::DataDeserializer.new(cup, roster_fallback: true).call
  end

  def swimmer_options_query
    @swimmer_options_query ||= GogglesDb::GogglesCup::SwimmerOptionsQuery.new(team_id: @team_id, base_year: @season_year)
  end

  def goggle_cups_for_selection
    return [] unless @team && @season_year

    GogglesDb::GoggleCup.where(team_id: @team.id, season_year: @season_year)
                        .order(:description)
  end

  # Distinct championship years having at least one cup for the managed domain
  # (all cups for admins), always including the current MASFIN year so a new
  # cup can be started for it even while browsing another year.
  def available_years
    base_scope = user_is_admin? ? GogglesDb::GoggleCup.all : GogglesDb::GoggleCup.where(team_id: managed_team_ids_for_user)
    (base_scope.distinct.pluck(:season_year) + [@season_year, current_championship_year]).compact.uniq.sort.reverse
  rescue StandardError
    [current_championship_year]
  end

  def managed_team_ids_for_user
    @managed_team_ids_for_user ||= GogglesDb::ManagedAffiliation
                                   .where(user_id: current_user.id)
                                   .joins(:team_affiliation)
                                   .distinct
                                   .pluck('team_affiliations.team_id')
  end

  def external_swimmers_for(cup)
    return [] unless cup && cup.swimmers_ids.present?

    team_swimmer_ids = swimmer_options_query.call.pluck(:swimmer_id)
    external_ids = cup.swimmer_ids_array - team_swimmer_ids
    return [] if external_ids.blank?

    GogglesDb::Swimmer.where(id: external_ids)
                      .pluck(:id, :complete_name, :year_of_birth)
                      .map { |r| { swimmer_id: r[0], swimmer_name: r[1], swimmer_year_of_birth: r[2] } }
  end

  def user_is_admin?
    @user_is_admin ||= GogglesDb::GrantChecker.admin?(current_user)
  end

  def set_no_duplicated_events
    @no_duplicated_events = ActiveModel::Type::Boolean.new.cast(params[:no_duplicated_events])
  end

  def no_duplicated_events_from(cup)
    goggle_cup_no_duplicated_events(cup)
  end

  def save_payload
    {
      team_id: @team&.id,
      season_year: @season_year, # cup's own year, or the checked editable year for new cups
      name: params[:name].presence || params[:description],
      description: params[:description],
      end_date: params[:end_date],
      swimmer_ids: Array(params[:swimmer_ids]).compact_blank.map(&:to_i)
    }
  end

  # Params carrying the current selection for redirects back to index.
  def back_params(overrides = {})
    { goggle_cup_id: @goggle_cup&.id, season_year: params[:season_year] || @season_year,
      team_id: @team&.id || params[:team_id] }.merge(overrides).compact
  end

  #-- -----------------------------------------------------------------------
  #++ API proxy

  # Calls goggles_api's GoggleCupManageAPI on behalf of the current user.
  # Returns { json: parsed_body } on success or { error: message } on failure.
  def goggle_cup_api_request(method, path, payload = nil)
    response = RestClient::Request.execute(
      method: method,
      url: "#{goggle_cup_api_base_url}#{path}",
      headers: api_request_headers,
      payload: payload&.to_json,
      timeout: 60
    )
    { json: JSON.parse(response.body.presence || '{}') }
  rescue RestClient::ExceptionWithResponse => e
    { error: api_error_detail(e) }
  rescue StandardError => e
    { error: e.message }
  end

  def goggle_cup_api_base_url
    "#{GogglesDb::AppParameter.config.settings(:framework_urls).api}/api/v3/goggle_cup_manage"
  end

  def api_request_headers
    jwt = GogglesDb::JWTManager.encode(
      { user_id: current_user.id },
      Rails.application.credentials.api_static_key
    )
    { 'Authorization' => "Bearer #{jwt}", accept: :json, content_type: :json }
  end

  # Error detail for the flash: the API's X-Error-Detail header or JSON
  # +error+ field; never the raw (possibly HTML) response body.
  def api_error_detail(exception)
    exception.response&.headers&.dig(:x_error_detail).presence ||
      api_error_from_json(exception.response&.body).presence ||
      exception.message
  end

  def api_error_from_json(body)
    parsed = JSON.parse(body.to_s)
    parsed['error'].to_s.truncate(200) if parsed.is_a?(Hash)
  rescue JSON::ParserError
    nil
  end

  # Redirects back to index with a notice on success, an alert on API failure.
  def redirect_after_mutation(result, success_message)
    if result[:error]
      redirect_to(goggle_cups_path(back_params), alert: t('goggle_cups.cup_save_error', errors: result[:error]))
    else
      redirect_to(goggle_cups_path(back_params), notice: success_message)
    end
  end

  # Renders the shared ranking partial for the AJAX compute response.
  def ranking_html(ranking_data)
    render_to_string(
      partial: 'goggle_cups/ranking',
      formats: [:html],
      locals: {
        team: @team,
        ranking_data: ranking_data,
        selected_swimmer_ids: Array(params[:swimmer_ids]).compact_blank,
        secondary_team_id: @secondary_team_id,
        no_duplicated_events: @no_duplicated_events == true,
        goggle_cup: @goggle_cup
      }
    )
  end
  #-- -----------------------------------------------------------------------
  #++

  def send_ranking_export(format:)
    @ranking_data = GogglesDb::GoggleCupRanking::DataDeserializer.new(@goggle_cup).call
    @no_duplicated_events = no_duplicated_events_from(@goggle_cup)
    return redirect_to(goggle_cups_path(back_params), alert: t('goggle_cups.info.no_ranking_data')) if @ranking_data.blank?

    result = GogglesDb::GoggleCupRanking::Exporter.new(
      cup: @goggle_cup, ranking_data: @ranking_data,
      no_duplicated_events: @no_duplicated_events
    ).export(format_name: format, export_type: params[:export_type])

    return redirect_to(goggle_cups_path, alert: t('goggle_cups.errors.invalid_selection_or_data')) if result.blank?

    send_data(result[:data], filename: result[:filename], type: result[:mime_type], disposition: 'attachment')
  end

  # rubocop:enable Metrics/ClassLength

  # Renders a turbo-stream alert inside #goggle-cup-ranking for stream requests,
  # or redirects to the given path with a flash alert for HTML requests.
  def respond_with_alert(alert_message, redirect_path = goggle_cups_path)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('goggle-cup-ranking',
                                                 partial: 'goggle_cups/alert',
                                                 locals: { message: alert_message })
      end
      format.html { redirect_to(redirect_path, alert: alert_message) }
      format.json { render json: { error: alert_message }, status: :unprocessable_content }
    end
  end
end
