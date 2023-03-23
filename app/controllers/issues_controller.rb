# frozen_string_literal: true

# = IssuesController
#
# rubocop:disable Metrics/ClassLength
class IssuesController < ApplicationController
  before_action :authenticate_user!

  # [GET] "HOW-TO"-like landing page with some integrated forms for
  # issues types "1a" (meeting URL), "3b" (swimmer association), "3c" (swimmer edit) & "4" (bug report).
  def faq_index; end

  # [GET] Index of actual issues created/reported by the current user
  def my_reports
    # TODO
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "0": request update to 'team manager'.
  def new_type0
    @type = '0'
    @issue_title = I18n.t('issues.type0.title')
    # WIP: Get just the last FIN Season for the time being:
    season_types = GogglesDb::SeasonType.all_masters
    @seasons = season_types.map { |season_type| GogglesDb::Season.last_season_by_type(season_type) }
    render('new')
  end

  # [POST] Create issue type "0": request update to 'team manager'.
  def create_type0
    unless request.post? && type0_params[:team_id].present? && type0_params[:season].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO: => use type0_params
    # params['team_id'] => team ID as str
    # params['team_label'] => team description w/ city
    # params['season'].values (to_i) => all checked season IDs
    # TODO: create issue report

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Create issue type "1a": new Meeting URL for data-import
  def create_type1a
    unless request.post? && type1a_params[:meeting_id].present? && type1a_params[:results_url].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO: => use type1a_params
    # "meeting_id"=>"19653",
    # "meeting_label"=>"21^ Trofeo Citta di Ravenna (2023-01-14)",
    # "city_id"=>"33", "city_label"=>"Pinarella", "city_area"=>"Ravenna",
    # "city_country_code"=>"[FILTERED]", "event_date"=>"2022-11-14",
    # "results_url"=>"test-url.org"
    # TODO
    # TODO: create issue report

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "1b": missing result in existing Meeting.
  #
  # rubocop:disable Metrics/AbcSize
  def new_type1b
    @parent_meeting = meeting_class_from_params.includes(:event_types, :pool_types)
                                               .find_by(id: type1b_params[:parent_meeting_id])
    unless @parent_meeting
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) and return
    end

    @type = '1b'
    @issue_title = I18n.t('issues.type1b.form.title')
    # Store preselected event type in cookies as we'll use the event_type_options() chrono helper for this:
    cookies[:event_type_id] = type1b_params[:event_type_id].to_i
    @swimmers = managed_swimmers(@parent_meeting.season_id)
    # TODO: After DB update:
    # @can_manage = GogglesDb::ManagerChecker.any_for?(current_user, parent_meeting.season)
    # WIP: remove this afterwards:
    @can_manage = GogglesDb::GrantChecker.admin?(current_user) ||
                  GogglesDb::ManagedAffiliation.includes(team_affiliation: %i[team season])
                                               .joins(team_affiliation: %i[team season])
                                               .exists?(
                                                 user_id: current_user.id,
                                                 'team_affiliations.season_id': @parent_meeting.season_id
                                               )
    render('new')
  end
  # rubocop:enable Metrics/AbcSize

  # [POST] Create issue type "1b": missing result in existing Meeting.
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create_type1b
    unless request.post? && type1b_params[:event_type_id].present? && type1b_params[:swimmer_id].present? &&
           type1b_params[:parent_meeting_id].present? && type1b_params[:parent_meeting_class].present? &&
           type1b_params[:minutes].present? && type1b_params[:seconds].present? && type1b_params[:hundredths].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO: create issue report
    # {"authenticity_token"=>"...", "event_type_id"=>"20", "event_type_label"=>"100 RANA",
    #  "swimmer_id"=>"142", "swimmer_label"=>"ALLORO STEFANO (MAS, 1969)",
    #  "swimmer_complete_name"=>"ALLORO STEFANO", "swimmer_first_name"=>"STEFANO", "swimmer_last_name"=>"ALLORO",
    #  "swimmer_year_of_birth"=>"1969", "gender_type_id"=>"1",
    #  "parent_meeting_id"=>"19647", "parent_meeting_class"=>"Meeting",
    #  "minutes"=>"1", "seconds"=>"24", "hundredths"=>"15" }

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "1b1": wrong result in existing Meeting.
  #
  # rubocop:disable Metrics/AbcSize
  def new_type1b1
    @result_row = result_class_from_params.includes(:swimmer, :event_type)
    @result_row = @result_row.includes(:team) if result_class_from_params.new.respond_to?(:team)
    @result_row = @result_row.find_by(id: type1b1_params[:result_id])
    unless @result_row
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) and return
    end

    @type = '1b1'
    @issue_title = I18n.t('issues.type1b1.form.title')
    # TODO: After DB update:
    # @can_manage = GogglesDb::ManagerChecker.any_for?(current_user, parent_meeting.season)
    # WIP: remove this afterwards:
    @can_manage = GogglesDb::GrantChecker.admin?(current_user) ||
                  GogglesDb::ManagedAffiliation.includes(team_affiliation: %i[team season])
                                               .joins(team_affiliation: %i[team season])
                                               .exists?(
                                                 user_id: current_user.id,
                                                 'team_affiliations.season_id': @result_row.parent_meeting.season_id
                                               )
    render('new')
  end
  # rubocop:enable Metrics/AbcSize

  # [POST] Create issue type "1b1": wrong result in existing Meeting.
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create_type1b1
    unless request.post? &&
           type1b1_params[:result_id].present? && type1b1_params[:result_class].present? &&
           type1b1_params[:minutes].present? && type1b1_params[:seconds].present? &&
           type1b1_params[:hundredths].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO
    # TODO: create issue report
    # {"authenticity_token"=>"...", "result_id"=>"1022151", "result_class"=>"MeetingIndividualResult",
    #  "minutes"=>"5", "seconds"=>"27", "hundredths"=>"27"}

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "2b1": wrong team, swimmer or meeting
  #
  # rubocop:disable Metrics/AbcSize
  def new_type2b1
    @result_row = result_class_from_params.includes(:swimmer, :event_type)
    @result_row = @result_row.includes(:team) if result_class_from_params.new.respond_to?(:team)
    @result_row = @result_row.find_by(id: type1b1_params[:result_id])
    unless @result_row
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) and return
    end

    @type = '2b1'
    @issue_title = I18n.t('issues.type1b1.form.title')
    # TODO: After DB update:
    # @can_manage = GogglesDb::ManagerChecker.any_for?(current_user, parent_meeting.season)
    # WIP: remove this afterwards:
    @can_manage = GogglesDb::GrantChecker.admin?(current_user) ||
                  GogglesDb::ManagedAffiliation.includes(team_affiliation: %i[team season])
                                               .joins(team_affiliation: %i[team season])
                                               .exists?(
                                                 user_id: current_user.id,
                                                 'team_affiliations.season_id': @result_row.parent_meeting.season_id
                                               )
    render('new')
  end
  # rubocop:enable Metrics/AbcSize

  # [POST] Create issue type "2b1": wrong team, swimmer or meeting
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create_type2b1
    unless request.post? &&
           type1b1_params[:result_id].present? && type1b1_params[:result_class].present? &&
           (type1b1_params[:wrong_meeting].present? || type1b1_params[:wrong_swimmer].present? ||
            type1b1_params[:wrong_team].present?)
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO
    # TODO: create issue report
    # {"authenticity_token"=>"...", "result_id"=>"1022151", "result_class"=>"MeetingIndividualResult",
    #  "wrong_meeting"=>"1", "wrong_team"=>"1"}

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Create issue type "3b": change swimmer association (free select)
  def create_type3b
    unless request.post? && type1b_params[:swimmer_id].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO
    # "swimmer_id"=>"142", "swimmer_label"=>"ALLORO STEFANO (MAL, 1969)",
    # "swimmer_complete_name"=>"ALLORO STEFANO", "swimmer_first_name"=>"STEFANO",
    # "swimmer_last_name"=>"ALLORO", "swimmer_year_of_birth"=>"1969",
    # "gender_type_id"=>"1"
    # TODO
    # TODO: create issue report

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end

  # [POST] Create issue type "3c": edit swimmer details (free text - may require confirm from user after parsing)
  def create_type3c
    unless request.post? && type3c_params[:type3c_first_name].present? && type3c_params[:type3c_last_name].present? &&
           type3c_params[:type3c_year_of_birth].present? && type3c_params[:type3c_gender_type_id].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO
    # "type3c_first_name"=>"STEFANO", "type3c_last_name"=>"ALLORO",
    # "type3c_year_of_birth"=>"1969", "type3c_gender_type_id"=>"1"
    # TODO
    # TODO: create issue report

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end

  # [POST] Create issue type "4": generic application error or bug
  # (w/ long description + context + desired goal)
  def create_type4
    unless request.post? && type4_params[:expected].present? && type4_params[:outcome].present? &&
           type4_params[:reproduce].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    # TODO
    # "expected"=>"Expected", "outcome"=>"outcome", "reproduce"=>"reproduce"
    # TODO: create issue report

    flash[:info] = I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Strong parameters checking for form type 0 ("update to 'team manager'")
  def type0_params
    params.permit(:authenticity_token, :team_id, :team_label, season: {})
  end

  # Strong parameters checking for form type 1a ("new Meeting URL")
  def type1a_params
    params.permit(:authenticity_token, :meeting_id, :meeting_label, :city_id, :city_label,
                  :city_area, :city_country_code, :event_date, :results_url)
  end

  # Strong parameters checking for form type 1b & 3b ("report missing" & "change swimmer association")
  def type1b_params
    params.permit(:authenticity_token, :parent_meeting_id, :parent_meeting_class, :event_type_id, :event_type_label,
                  :minutes, :seconds, :hundredths, :swimmer_id, :swimmer_label, :swimmer_complete_name,
                  :swimmer_first_name, :swimmer_last_name, :swimmer_year_of_birth, :gender_type_id)
  end

  # Strong parameters checking for form type 1b1 & 2b1 ("report mistake")
  def type1b1_params
    params.permit(:authenticity_token, :result_id, :result_class, :wrong_meeting, :wrong_swimmer, :wrong_team,
                  :minutes, :seconds, :hundredths)
  end

  # Strong parameters checking for form type 3c ("edit swimmer details")
  def type3c_params
    params.permit(:authenticity_token, :type3c_first_name, :type3c_last_name, :type3c_year_of_birth, :type3c_gender_type_id)
  end

  # Strong parameters checking for form type 3c ("edit swimmer details")
  def type4_params
    params.permit(:authenticity_token, :expected, :outcome, :reproduce)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the correct sibling class for the AbstractMeeting, given the :parent_meeting_class parameter.
  def meeting_class_from_params
    return GogglesDb::Meeting if type1b_params[:parent_meeting_class].to_s.include?('Meeting')

    GogglesDb::UserWorkshop
  end

  # Returns the correct sibling class for the AbstractResult, given the :result_class parameter.
  def result_class_from_params
    return GogglesDb::MeetingIndividualResult if type1b1_params[:result_class].to_s.include?('IndividualResult')

    GogglesDb::UserResult
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the list of available managed swimmers for the current user, given the season_id.
  # This will be used for preset values in DbSwimmerComponent options.
  def managed_swimmers(season_id)
    # If the list of available swimmers is nil, the swimmer select will be disabled by default.
    # But if the user is also an admin, returning nil will allow any API search for swimmers.
    return if GogglesDb::GrantChecker.admin?(current_user)

    managed_teams_ids = GogglesDb::ManagedAffiliation.includes(team_affiliation: %i[team season])
                                                     .joins(team_affiliation: %i[team season])
                                                     .where(user_id: current_user.id,
                                                            'team_affiliations.season_id': season_id)
                                                     .map { |ma| ma.team_affiliation.team_id }
                                                     .uniq
    GogglesDb::Badge.where(season_id: season_id, team_id: managed_teams_ids)
                    .map(&:swimmer)
                    .uniq
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Metrics/ClassLength
