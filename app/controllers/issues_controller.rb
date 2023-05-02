# frozen_string_literal: true

# = IssuesController
#
# rubocop:disable Metrics/ClassLength
class IssuesController < ApplicationController
  before_action :authenticate_user!

  # Whenever this top limit of currently existing Issues for a single user is hit, the system refuses to create more rows
  SPAM_LIMIT = 30

  # [GET] "HOW-TO"-like landing page with some integrated forms for
  # issues types "1a" (meeting URL), "3b" (swimmer association), "3c" (swimmer edit) & "4" (bug report).
  def faq_index; end

  # [GET] Index of actual issues created/reported by the current user
  def my_reports
    @grid = IssuesGrid.new(grid_filter_params) do |scope|
      scope.for_user(current_user).page(index_params[:page]).per(8)
    end
  end

  # [DELETE /issues/destroy/:id] Free row delete for any generated issue
  def destroy
    unless request.delete? && GogglesDb::Issue.exists?(delete_params[:id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    row = GogglesDb::Issue.find_by(id: delete_params[:id])
    if row&.destroy
      flash[:notice] = t('issues.grid.delete_done')
    else
      flash[:error] = t('issues.grid.delete_error')
    end
    redirect_to(issues_my_reports_path)
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "0": request update to 'team manager'.
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def new_type0
    @type = '0'
    @issue_title = I18n.t('issues.type0.title')
    # WIP: Get just the last FIN Season for the time being:
    season_types = GogglesDb::SeasonType.all_masters
    @seasons = season_types.map { |season_type| GogglesDb::Season.last_season_by_type(season_type) }
    render('new')
  end

  # [POST] Create issue type "0": request update to 'team manager'.
  # WARNING: allows to create a type0 even if team_id doesn't match exactly with the manually input :team_label
  #          => Admin must check that the corresponding team ID actually is the same one as requested.
  def create_type0
    team_id = type0_params[:team_id] if type0_params[:team_id].present? && GogglesDb::Team.exists?(id: type0_params[:team_id])
    # Allow non-existing partial matches to be used too, in case the name is wrong:
    team_id ||= GogglesDb::Team.for_name(type0_params[:team_label]).first&.id if type0_params[:team_label].present?
    unless request.post? && team_id.present? && type0_params[:season].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    skip = false
    season_ids = type0_params[:season].values
                                      .filter_map { |id| GogglesDb::Season.exists?(id) ? id : nil }

    season_ids.each do |season_id|
      (skip = true) && next if GogglesDb::ManagerChecker.new(current_user, season_id).for_team?(team_id)

      create_issue('0', { team_id: team_id, team_label: type0_params[:team_label], season_id: season_id })
      break if flash[:error].present? # Break out in case of errors
    end

    flash[:info] = skip ? I18n.t('issues.type0.msg.some_existing_were_skipped') : I18n.t('issues.sent_ok')
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Create issue type "1a": new Meeting URL for data-import
  def create_type1a
    unless request.post? && type1a_params[:results_url].present? &&
           (type1a_params[:meeting_id].present? || type1a_params[:meeting_label].present?)
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('1a', type1a_params)
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "1b": missing result in existing Meeting.
  #
  def new_type1b
    @parent_meeting = meeting_class_from_params.includes(:event_types, :pool_types)
                                               .find_by(id: type1b_params[:parent_meeting_id])
    unless @parent_meeting
      flash.now[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) and return
    end

    @type = '1b'
    @issue_title = I18n.t('issues.type1b.form.title')
    # Store preselected event type in cookies as we'll use the event_type_options() chrono helper for this:
    cookies[:event_type_id] = type1b_params[:event_type_id].to_i
    @swimmers = managed_swimmers(@parent_meeting.season_id)
    @can_manage = GogglesDb::ManagerChecker.any_for?(current_user, @parent_meeting.season_id)
    render('new')
  end

  # [POST] Create issue type "1b": missing result in existing Meeting.
  #
  def create_type1b
    unless request.post? && type1b_params[:event_type_id].present? && type1b_params[:swimmer_id].present? &&
           type1b_params[:parent_meeting_id].present? && type1b_params[:parent_meeting_class].present? &&
           type1b_params[:minutes].present? && type1b_params[:seconds].present? && type1b_params[:hundredths].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('1b', type1b_params)
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "1b1": wrong result in existing Meeting.
  #
  def new_type1b1
    @result_row = result_class_from_params.includes(:swimmer, :event_type)
    @result_row = @result_row.includes(:team) if result_class_from_params.new.respond_to?(:team)
    @result_row = @result_row.find_by(id: type1b1_params[:result_id])
    unless @result_row
      flash.now[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) and return
    end

    @type = '1b1'
    @issue_title = I18n.t('issues.type1b1.form.title')
    @can_manage = GogglesDb::ManagerChecker.any_for?(current_user, @result_row.parent_meeting.season_id)
    render('new')
  end

  # [POST] Create issue type "1b1": wrong result in existing Meeting.
  #
  def create_type1b1
    unless request.post? &&
           type1b1_params[:result_id].present? && type1b1_params[:result_class].present? &&
           type1b1_params[:minutes].present? && type1b1_params[:seconds].present? &&
           type1b1_params[:hundredths].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end

    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('1b1', type1b1_params)
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form setup for issue type "2b1": wrong team, swimmer or meeting
  #
  def new_type2b1
    @result_row = result_class_from_params.includes(:swimmer, :event_type)
    @result_row = @result_row.includes(:team) if result_class_from_params.new.respond_to?(:team)
    @result_row = @result_row.find_by(id: type1b1_params[:result_id])
    unless @result_row
      flash.now[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) and return
    end

    @type = '2b1'
    @issue_title = I18n.t('issues.type1b1.form.title')
    @can_manage = GogglesDb::ManagerChecker.any_for?(current_user, @result_row.parent_meeting.season_id)
    render('new')
  end

  # [POST] Create issue type "2b1": wrong team, swimmer or meeting
  def create_type2b1
    unless request.post? &&
           type1b1_params[:result_id].present? && type1b1_params[:result_class].present? &&
           (type1b1_params[:wrong_meeting].present? || type1b1_params[:wrong_swimmer].present? ||
            type1b1_params[:wrong_team].present?)
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('2b1', type1b1_params)
    redirect_to(issues_my_reports_path) and return
  end
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Create issue type "3b": change swimmer association (free select)
  def create_type3b
    unless request.post? && type1b_params[:swimmer_id].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('3b', type1b_params)
    redirect_to(issues_my_reports_path) and return
  end

  # [POST] Create issue type "3c": edit swimmer details (free text - may require confirm from user after parsing)
  def create_type3c
    unless request.post? && type3c_params[:type3c_first_name].present? && type3c_params[:type3c_last_name].present? &&
           type3c_params[:type3c_year_of_birth].present? && type3c_params[:type3c_gender_type_id].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(issues_my_reports_path) and return
    end
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('3c', type3c_params)
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
    if GogglesDb::Issue.for_user(current_user).processable.count >= SPAM_LIMIT
      flash[:warning] = I18n.t('issues.spam_notice')
      redirect_to(issues_my_reports_path) and return
    end

    create_issue('4', type4_params)
    redirect_to(issues_my_reports_path) and return
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  protected

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Default whitelist for datagrid parameters
  # (NOTE: member variable is needed by the view)
  def grid_filter_params
    @grid_filter_params = params.fetch(:issues_grid, {})
                                .permit(:code, :status, :descending, :order)
  end

  private

  # Parameter checking for DELETE /delete (only :id shall be used)
  def delete_params
    params.permit(%w[id authenticity_token commit])
  end

  # Strong parameters checking for form type 0 ("update to 'team manager'")
  def type0_params
    params.permit(:team_id, :team_label, season: {})
  end

  # Strong parameters checking for form type 1a ("new Meeting URL")
  def type1a_params
    params.permit(:meeting_id, :meeting_label, :city_id, :city_label,
                  :city_area, :city_country_code, :event_date, :results_url)
  end

  # Strong parameters checking for form type 1b & 3b ("report missing" & "change swimmer association")
  def type1b_params
    params.permit(:parent_meeting_id, :parent_meeting_class, :event_type_id, :event_type_label,
                  :minutes, :seconds, :hundredths, :swimmer_id, :swimmer_label, :swimmer_complete_name,
                  :swimmer_first_name, :swimmer_last_name, :swimmer_year_of_birth, :gender_type_id)
  end

  # Strong parameters checking for form type 1b1 & 2b1 ("report mistake")
  def type1b1_params
    params.permit(:result_id, :result_class, :wrong_meeting, :wrong_swimmer, :wrong_team,
                  :minutes, :seconds, :hundredths)
  end

  # Strong parameters checking for form type 3c ("edit swimmer details")
  def type3c_params
    params.permit(:type3c_first_name, :type3c_last_name, :type3c_year_of_birth, :type3c_gender_type_id)
  end

  # Strong parameters checking for form type 3c ("edit swimmer details")
  def type4_params
    params.permit(:expected, :outcome, :reproduce)
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

  # Creates a new issue record, checking result and setting a proper flash message.
  def create_issue(type_code, req_params)
    issue = GogglesDb::Issue.new(user_id: current_user.id, code: type_code, req: req_params.to_json)
    if issue.save
      flash[:info] = I18n.t('issues.sent_ok')
    else
      error_msg = issue.errors.messages.map { |col, errs| "'#{col}' #{errs.join(', ')}" }.join('; ')
      flash[:error] = I18n.t('issues.creation_error', error: error_msg)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Metrics/ClassLength
