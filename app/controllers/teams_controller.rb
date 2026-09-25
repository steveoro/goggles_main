# frozen_string_literal: true

# = TeamsController
#
class TeamsController < ApplicationController
  before_action :authenticate_user!, only: %i[current_swimmers records]
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

  # GET /teams/records/:id
  # Shows the individual records for a team ("team records" matrix): the single
  # best timing per (event x category x gender x pool) tuple, ever or filtered
  # by championship year.
  # Requires authentication and an existing team.
  #
  # == Params
  # - :id => *Team* ID, required
  # - :season_year => optional championship (begin) year for the season tabs;
  #   limited to the latest 5 available championship years for the team,
  #   defaults to the most recent one
  # - :tab => 'all_time' (default) or 'by_season'
  # - format => html (default) or pdf
  def records
    if @team.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    prepare_records_data

    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeamRecordsPdf.new(team: @team, records: @records,
                                 season_year: (@season_year if @active_tab == 'by_season'))
        send_data(pdf.render, filename: pdf.filename, type: pdf.mime_type, disposition: 'attachment')
      end
    end
  end

  protected

  # /show action strong parameters checking
  def team_params
    params.permit(:id, :team_affiliation_id)
  end

  # /records action strong parameters checking
  def records_params
    params.permit(:id, :season_year, :tab)
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
                                .order('seasons.begin_date')
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

  # Prepares the member variables used by the /records views:
  # @championship_years, @season_year, @active_tab and @records.
  # The selectable championship years are capped to the latest 5 for the team;
  # any other :season_year value falls back to the most recent one.
  def prepare_records_data
    @championship_years = seasons_by_championship_year.keys.sort.last(5).reverse
    @season_year = records_params[:season_year].to_i
    @season_year = @championship_years.first unless @championship_years.include?(@season_year)
    @active_tab = records_params[:tab].presence_in(%w[by_season]) ||
                  (records_params[:season_year].present? ? 'by_season' : 'all_time')

    season_ids = nil
    season_ids = seasons_by_championship_year.fetch(@season_year, []).map(&:id) if @active_tab == 'by_season'
    @records = GogglesDb::BestTeamResultsForSeason.team_records(@team.id, season_ids)
                                                  .includes(:event_type, :category_type, :gender_type,
                                                            :pool_type, :meeting,
                                                            meeting_individual_result: :meeting_program)
  end

  # Computes the championship year for a season following the
  # best_swimmer_current_vs_previous_results view convention:
  # Sep-Dec start => YEAR(begin_date); Jan-May start => YEAR(begin_date) - 1;
  # Jun-Aug start => YEAR(end_date).
  def championship_year_for(season)
    return if season.begin_date.blank? || season.end_date.blank?

    if season.begin_date.month >= 9
      season.begin_date.year
    elsif season.begin_date.month <= 5
      season.begin_date.year - 1
    else
      season.end_date.year
    end
  end

  # All seasons for the team's affiliations, grouped by championship year.
  # Used both for the "by season" selector and to filter the records scope.
  def seasons_by_championship_year
    @seasons_by_championship_year ||= GogglesDb::Season
                                      .where(id: @team.team_affiliations.select(:season_id))
                                      .group_by { |season| championship_year_for(season) }
                                      .reject { |year, _seasons| year.nil? }
  end
end
