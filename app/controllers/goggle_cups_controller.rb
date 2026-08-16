# frozen_string_literal: true

# = GoggleCupsController
#
# Read-only Goggle Cup browsing for team managers and admins.
# Users select a championship/base year and a team, then choose from the
# pre-computed cups stored for that team/year to see the stored ranking.
#
class GoggleCupsController < ApplicationController
  helper_method :user_is_admin?
  before_action :authenticate_user!
  before_action :validate_manager_or_admin!
  before_action :prepare_managed_teams_for_cups
  before_action :set_selected_team, only: %i[index ranking]
  before_action :set_season_year, only: %i[index ranking]
  before_action :set_goggle_cup, only: %i[ranking]

  # [GET] Renders the Goggle Cup browsing/selection page.
  def index
    @available_years = available_years
    @goggle_cups = goggle_cups_for_selection
  end

  # [GET] Streams the stored ranking for the selected cup.
  def ranking
    return respond_with_alert(t('goggle_cups.info.no_ranking_data')) if @goggle_cup.ranking_data.blank?

    @selected_team = @goggle_cup.team
    @selected_team_id = @goggle_cup.team_id
    @season_year ||= @goggle_cup.season_year
    @ranking_data = GogglesDb::GoggleCupRanking::DataDeserializer.new(@goggle_cup).call
    @no_duplicated_events = no_duplicated_events_from(@goggle_cup)
    @available_years = available_years
    @goggle_cups = goggle_cups_for_selection

    respond_to do |format|
      format.turbo_stream
      format.html { render(:index) }
    end
  end

  private

  def validate_manager_or_admin!
    return if user_is_admin? || managed_team_ids_for_user.present?

    respond_with_alert(t('goggle_cups.unauthorized'), root_path)
  end

  def prepare_managed_teams_for_cups
    if user_is_admin?
      @managed_team_ids = nil
      @managed_teams = nil
    else
      @managed_team_ids = managed_team_ids_for_user
      @managed_teams = GogglesDb::Team.where(id: @managed_team_ids)
      @current_user_is_manager = @managed_team_ids.present?
    end
  end

  def set_selected_team
    @selected_team_id = params[:team_id].presence
    return if @selected_team_id.blank?

    @selected_team = GogglesDb::Team.find_by(id: @selected_team_id)
    return respond_with_alert(t('goggle_cups.team_not_found')) if @selected_team.blank?
    return if user_is_admin? || @managed_team_ids.include?(@selected_team_id.to_i)

    respond_with_alert(t('goggle_cups.unauthorized_team'), root_path)
  end

  def set_season_year
    year = params[:season_year].presence&.to_i
    year = available_years.first if year.blank? && available_years.present?
    @season_year = year.presence || Date.current.year
  end

  def set_goggle_cup
    @goggle_cup = GogglesDb::GoggleCup.find_by(id: params[:id])
    return respond_with_alert(t('goggle_cups.cup_not_found')) if @goggle_cup.blank?
    return if user_is_admin? || @managed_team_ids.include?(@goggle_cup.team_id)

    respond_with_alert(t('goggle_cups.unauthorized_team'), root_path)
  end

  def goggle_cups_for_selection
    return [] unless @selected_team && @season_year

    GogglesDb::GoggleCup.where(team_id: @selected_team.id, season_year: @season_year)
                        .order(:description)
  end

  def available_years
    base_scope = user_is_admin? ? GogglesDb::GoggleCup.all : GogglesDb::GoggleCup.where(team_id: @managed_team_ids)
    base_scope.distinct.pluck(:season_year).compact.sort.reverse
  rescue StandardError
    []
  end

  def managed_team_ids_for_user
    @managed_team_ids_for_user ||= GogglesDb::ManagedAffiliation
                                   .where(user_id: current_user.id)
                                   .joins(:team_affiliation)
                                   .distinct
                                   .pluck('team_affiliations.team_id')
  end

  def user_is_admin?
    @user_is_admin ||= GogglesDb::GrantChecker.admin?(current_user)
  end

  def no_duplicated_events_from(cup)
    data = cup.ranking_data
    return false if data.blank?

    parsed = data.is_a?(String) ? JSON.parse(data) : data
    value = parsed['no_duplicated_events']
    value.nil? ? false : ActiveModel::Type::Boolean.new.cast(value)
  rescue StandardError
    false
  end

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
    end
  end
end
