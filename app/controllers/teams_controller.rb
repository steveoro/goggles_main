# frozen_string_literal: true

# = TeamsController
#
class TeamsController < ApplicationController
  before_action :authenticate_user!, only: [:current_swimmers]
  before_action :prepare_team

  # Show details & main stats for a team
  # == Params
  # - :id, required
  def show
    return unless @team.nil?

    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end

  # GET /teams/current_swimmers
  # Shows the current swimmers for a team.
  # Requires authentication.
  #
  # == Params
  # - :id => *Team* ID, required; the team id will be stored in the cookies and updated each time.
  def current_swimmers
    if @team.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    # 1. get all last affiliations per type:
    last_affiliations = GogglesDb::SeasonType.all_masters.map do |season_type|
      GogglesDb::TeamAffiliation.includes(:team, season: :season_type)
                                .joins(:team, season: :season_type)
                                .where(team_id: @team.id, seasons: { season_type_id: season_type.id })
                                .order(:begin_date)
                                .last
    end
    @last_affiliations_ids = last_affiliations.compact.map(&:id)

    # 2. get all (unique) swimmers having a badge for the found affiliations
    @swimmers = GogglesDb::Swimmer.includes(:badges, :gender_type)
                                  .joins(:badges, :gender_type)
                                  .where(badges: { team_affiliation_id: @last_affiliations_ids })
                                  .distinct
                                  .order(:complete_name, :year_of_birth)

    # 3. get all badges for each affiliation (used to get a list of badges per swimmer)
    @latest_badges = GogglesDb::Badge.where(team_affiliation_id: @last_affiliations_ids)
  end

  protected

  # /show action strong parameters checking
  def team_params
    params.permit(:id)
  end

  private

  # Setter for the @team member variable either based on params or cookies.
  # Updates the cookies with the new value.
  def prepare_team
    @team = GogglesDb::Team.find_by(id: team_params[:id])
    @team ||= GogglesDb::Team.find_by(id: cookies[:team_id]) if cookies[:team_id].present?
    cookies[:team_id] = @team.id if @team.present?
  end
end
