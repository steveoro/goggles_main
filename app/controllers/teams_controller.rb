# frozen_string_literal: true

# = TeamsController
#
class TeamsController < ApplicationController
  before_action :authenticate_user!, only: [:current_swimmers]
  before_action :prepare_team

  # GET /teams/:id
  # Show details & main stats for a team. AKA: Team radiography.
  # Requires an existing Team.
  #
  # == Params
  # - :id, required
  def show
    if @team.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @stats = GogglesDb::TeamStat.new(@team)
  end

  # GET /teams/current_swimmers/:id
  # Shows the current swimmers for a team.
  # Requires authentication and an existing team.
  #
  # == Params
  # - :id => *Team* ID, required; the team id will be stored in the cookies and updated each time.
  # - :team_affiliation_id => TeamAffiliation ID, optional; the affiliation id for the team; when missing, the first one
  #   among the last affiliations will be used.
  def current_swimmers
    if @team.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    # 1. get all last affiliations per type:
    prepare_last_affiliations
    # 2. get all (unique) swimmers having a badge for the selected affiliation:
    prepare_swimmers
    # 3. get all badges for the team affiliation's season type, so that we can later filter them by swimmer:
    prepare_badges
  end

  protected

  # /show action strong parameters checking
  def team_params
    params.permit(:id, :team_affiliation_id)
  end

  private

  # Setter for the @team member variable either based on params or cookies and also for the @team_affiliation member
  # variable based on params.
  # Updates the cookies with the new value.
  def prepare_team
    @team = GogglesDb::Team.find_by(id: team_params[:id])
    @team_affiliation = GogglesDb::TeamAffiliation.find_by(id: team_params[:team_affiliation_id]) if team_params[:team_affiliation_id].present?
    @team ||= GogglesDb::Team.find_by(id: cookies[:team_id]) if cookies[:team_id].present?
    cookies[:team_id] = @team.id if @team.present?
  end

  # Setter for the @last_affiliations & @team_affiliation member variables.
  def prepare_last_affiliations
    @last_affiliations = GogglesDb::SeasonType.all_masters.map do |season_type|
      GogglesDb::TeamAffiliation.includes(:team, season: :season_type).joins(:team, season: :season_type)
                                .where(team_id: @team.id, seasons: { season_type_id: season_type.id })
                                .order(:begin_date)
                                .last
    end
    @last_affiliations.compact!
    @team_affiliation ||= @last_affiliations.first
    @last_affiliations
  end

  # Setter for the @swimmers member variable.
  def prepare_swimmers
    @swimmers = GogglesDb::Swimmer.includes(:badges, :gender_type).joins(:badges, :gender_type)
                                  .where(badges: { team_affiliation_id: @team_affiliation })
                                  .distinct
                                  .order(:complete_name, :year_of_birth)
  end

  # Setter for the @all_badges_per_type member variable.
  def prepare_badges
    @all_badges_per_type = GogglesDb::Badge.for_team(@team)
                                           .includes(season: [:federation_type])
                                           .where(
                                             swimmer_id: @swimmers.pluck(:id),
                                             team_affiliation_id: @last_affiliations.pluck(:id)
                                           )
                                           .by_season
  end
end
