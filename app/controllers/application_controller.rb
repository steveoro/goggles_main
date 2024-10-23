# frozen_string_literal: true

require 'version'

# = ApplicationController
#
# Common parent controller
class ApplicationController < ActionController::Base # rubocop:disable Metrics/ClassLength
  protect_from_forgery with: :exception
  before_action :app_settings_row, :set_locale, :detect_device_variant, :check_maintenance_mode,
                :update_stats, :prepare_last_seasons
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  # Prosopite will work only when enabled in config/environments/<ENV>.rb
  if Rails.env.test? || Rails.env.development?
    around_action :n_plus_one_detection

    def n_plus_one_detection
      Prosopite.scan
      yield
    ensure
      Prosopite.finish
    end
  end

  # Catch-all redirect in case of 404s
  def redirect_missing
    flash[:error] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end

  protected

  # Memoize base app settings
  def app_settings_row
    @app_settings_row ||= GogglesDb::AppParameter.versioning_row
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepares the arrays for all supported and recent season rows found together with
  # their corresponding IDs.
  #
  # Sets the internal members:
  # - <tt>@last_seasons</tt>
  #   Array of all the latest GogglesDb::Season rows found (one per type); an empty array otherwise.
  #
  # - <tt>@last_seasons_ids</tt>
  #   Collection of all the IDs from <tt>@last_seasons</tt>.
  #
  # - <tt>@current_user_is_manager</tt>
  #   +true+ if current user can manage any affiliations belonging to the found <tt>@last_seasons</tt>.
  #   Further affiliation filtering (by team) should happen after the user selects any actions which
  #   requires selecting a specific managed team.
  #
  # - <tt>@current_user_is_admin</tt>
  #   +true+ if current user has admin grants
  #
  def prepare_last_seasons
    @last_seasons_ids = last_season_ids
    @last_seasons = GogglesDb::Season.unscoped.where(id: @last_seasons_ids) if @last_seasons.blank?

    # Can we show any management button related to these seasons? (team selection should happen afterwards)
    @current_user_is_admin = GogglesDb::GrantChecker.admin?(current_user)
    @current_user_is_manager = @last_seasons_ids.present? && user_signed_in? &&
                               GogglesDb::ManagedAffiliation.includes(team_affiliation: %i[team season])
                                                            .joins(team_affiliation: %i[team season])
                                                            .exists?(user_id: current_user.id, 'seasons.id': @last_seasons_ids)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepares the array storing all available Teams for the current user (if any);
  # defaults to an empty array otherwise.
  # Safe to be called multiple times with different list of IDs.
  #
  # == Params:
  # - season_ids: an array of Season#IDs or []
  #
  # == Result:
  # *Updates* the internal member:
  # - <tt>@user_teams</tt> => array of all the GogglesDb::Team rows associated to the current_user,
  #                           (if the current user has an associated swimmer)
  #
  # If <tt>@user_teams</tt> is already set, calling again the helper will just add the unique teams
  # from the swimmer's badges of the specified seasons.
  #
  def update_user_teams_for_seasons_ids(season_ids)
    @user_teams ||= []
    return unless user_signed_in? && season_ids.present? && current_user.swimmer

    @user_teams += GogglesDb::Badge.where(season_id: season_ids, swimmer_id: current_user.swimmer_id)
                                   .map(&:team).uniq
    @user_teams.uniq!
  end

  # Specialized/default version of the helper above, specific for @last_season_ids only.
  #
  # Uses @last_seasons_ids.
  #
  # == Result:
  # *Updates* the internal member:
  # - <tt>@user_teams</tt> => array of all the GogglesDb::Team rows associated to the current_user,
  #                           (if the current user has an associated swimmer)
  #
  # If <tt>@user_teams</tt> is already set, calling again the helper will just add the unique teams
  # from the swimmer's badges of the specified seasons.
  #
  def prepare_user_teams
    update_user_teams_for_seasons_ids(@last_seasons_ids)
  end

  # Similarly to #prepare_user_teams, this one collects all available and *managed* Teams
  # for the current user (if any) which have an affiliation belonging to one of specified seasons IDs.
  # Defaults to an empty array otherwise; +nil+ only for admins (to avoid listing all teams).
  #
  # == Params:
  # - season_ids: an array of Season#IDs or []
  #
  # Uses @current_user_is_admin.
  #
  # == Result:
  # *Updates* the internal members:
  #
  # - <tt>@current_user_is_manager</tt> =>
  #  Sets this to +true+ if there's a TeamAffiliation in the specified season IDs
  #  that is also managed by the current user (if is logged in).
  #
  # - <tt>@managed_teams</tt> =>
  #  Array of all unique GogglesDb::Team rows found, managed the current_user and
  #  belonging to any one of the @last_seasons_ids found.
  #
  # - <tt>@managed_team_ids</tt> =>
  #  Same as above, but lists just the IDs for convenience.
  #
  # == Possible values for both:
  #  row array => managed team rows / lists which exact IDs are managed
  #  +empty+   => no team managed
  #  +nil+     => all teams managed (admin: true, skips checks)
  #
  def update_managed_teams_for_seasons_ids(season_ids)
    if @current_user_is_admin
      @managed_teams = @managed_team_ids = nil # signal that all teams are managed by Admins
      return
    end

    # Fill the managed-teams filtering arrays only when not an admin:
    managed_team_ids_for_season = if user_signed_in?
                                    GogglesDb::ManagedAffiliation.includes(:team_affiliation)
                                                                 .joins(:team_affiliation)
                                                                 .where(user_id: current_user.id, 'team_affiliations.season_id': season_ids)
                                                                 .pluck(:team_id)
                                                                 .uniq
                                  else
                                    []
                                  end
    @managed_team_ids ||= []
    @managed_team_ids += managed_team_ids_for_season if managed_team_ids_for_season.present?
    @managed_team_ids.uniq!
    @managed_teams = GogglesDb::Team.where(id: @managed_team_ids)
    @current_user_is_manager = user_signed_in? && managed_team_ids_for_season.present?
  end

  # Specialized/default version of the helper above, specific for @last_season_ids only.
  #
  # Uses @last_seasons_ids & @current_user_is_admin.
  #
  # == Result:
  # *Updates* the internal members:
  #
  # - <tt>@current_user_is_manager</tt> =>
  #  Sets this to +true+ if there's a TeamAffiliation in the specified season IDs
  #  that is also managed by the current user (if is logged in).
  #
  # - <tt>@managed_teams</tt> =>
  #  Array of all unique GogglesDb::Team rows found, managed the current_user and
  #  belonging to any one of the @last_seasons_ids found.
  #
  # - <tt>@managed_team_ids</tt> =>
  #  Same as above, but lists just the IDs for convenience.
  #
  def prepare_managed_teams
    update_managed_teams_for_seasons_ids(@last_seasons_ids)
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Sets the current application locale given the :locale request parameter or
  # the existing cookie value. Falls back on the default locale instead.
  #
  # The cookie :locale will be updated each time; the locale value is checked
  # against the defined available locales.
  #
  # == Precedence:
  #
  # 1. params[:locale]
  # 2. cookies[:locale]
  # 3. I18n.default_locale
  #
  # rubocop:disable Metrics/PerceivedComplexity
  def set_locale
    # NOTE: in order to avoid DOS-attacks by creating ludicrous amounts of Symbols,
    # create a string map of the available locales and set the I18n.locale only
    # when the string parameter actually belongs to this set.

    # Memoize the list of available/acceptable locales (this won't change unless server is restarted):
    @accepted_locales ||= I18n.available_locales.map(&:to_s)

    locale = params[:locale] if @accepted_locales.include?(params[:locale])
    if locale.nil?
      # Use the cookie only when set or enabled:
      locale = cookies[:locale] if @accepted_locales.include?(cookies[:locale])
    else
      # Store the chosen locale when it changes
      cookies[:locale] = locale
    end

    current_locale = locale || I18n.default_locale # (default case when cookies are disabled)
    return unless @accepted_locales.include?(current_locale.to_s)

    I18n.locale = current_locale.to_sym
    logger.debug("* Locale is now set to '#{I18n.locale}'")
  end
  # rubocop:enable Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # Sets the internal @browser instance used to detect 'request.variant' type
  # depending on 'request.user_agent'.
  # (In order to be processed by Rails, customized layouts and views will be given
  #  a "+<VARIANT>.EXT" suffix.)
  #
  # @see https://github.com/fnando/browser
  def detect_device_variant
    # Detect browser type:
    @browser = Browser.new(request.user_agent)
    request.variant = :mobile if @browser.device.mobile? && !@browser.device.tablet?
    # Add here more variants when needed:
    # request.variant = :tablet if @browser.device.tablet?
    # request.variant = :desktop if @browser.device.ipad?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Checks if maintenance mode is enbled, redirecting to the maintenance page.
  def check_maintenance_mode
    # Allow only legit requests while avoiding infinite redirect loop:
    if GogglesDb::AppParameter.maintenance? && (params[:controller] != 'maintenance')
      redirect_to maintenance_path
    elsif !GogglesDb::AppParameter.maintenance? && (params[:controller] == 'maintenance')
      redirect_to root_path
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Updates the internal statistical counters for daily request load.
  #
  # === NOTE:
  # This 'api_daily_uses' table should be cleaned up from older entries at least once
  # a week to prevent the DB from bloating excessively in size.
  #
  # Not being interested at all in tracking the behaviour of each user, we just count the
  # overall individual requests in order to scale the server host accordingly when the
  # need arises. There is currently no implemented way for knowing the *individual page views*
  # except for the basic request load.
  #
  # This "quick'n'ugly" solution currently works just because we don't get over the limit
  # of a few hundreds users a day. We'll move to a stand-alone, self-hosted dockerized
  # solution like Plausible Analytics should this ever be needed.
  #
  def update_stats
    # This custom stats key allows to compute quickly the average request load per user, as well
    # as the total users per day:
    GogglesDb::APIDailyUse.increase_for!("REQ-#{request.ip}")
  end
  #-- -------------------------------------------------------------------------
  #++

  # Adds all the bespoke field keys that can be updated during certain Devise controller actions
  def configure_devise_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name first_name last_name description year_of_birth swimmer_id])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name first_name last_name description year_of_birth swimmer_id])
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the last chosen Swimmer from the cookies or the default one besed on the current user.
  def last_chosen_swimmer
    return GogglesDb::Swimmer.find_by(id: cookies[:swimmer_id]) if cookies[:swimmer_id].to_i.positive?

    if cookies[:swimmer_complete_name].present?
      return GogglesDb::Swimmer.new(
        complete_name: cookies[:swimmer_complete_name],
        year_of_birth: cookies[:swimmer_year_of_birth],
        gender_type_id: cookies[:gender_type_id]
      )
    end

    current_user.swimmer
  end

  # Returns the last chosen SwimmingPool values restored from the cookies, or nil.
  def last_chosen_swimming_pool
    return nil unless cookies[:swimming_pool_id].to_i.positive? || cookies[:swimming_pool_name].present?

    GogglesDb::SwimmingPool.find_by(id: cookies[:swimming_pool_id]) ||
      GogglesDb::SwimmingPool.new(
        name: cookies[:swimming_pool_name],
        pool_type_id: cookies[:pool_type_id]
      )
  end

  # Returns the last chosen Team values restored from the cookies or nil.
  def last_chosen_team
    return nil unless cookies[:team_id].to_i.positive? || cookies[:team_name].present? || cookies[:team_label].present?

    GogglesDb::Team.find_by(id: cookies[:team_id]) ||
      GogglesDb::Team.new(
        name: cookies[:team_name] || cookies[:team_label],
        editable_name: cookies[:team_name]
      )
  end

  # Returns the last chosen City values restored from the cookies or nil.
  def last_chosen_city
    return nil unless cookies[:city_id].to_i.positive? || cookies[:city_name].present? || cookies[:city_label].present?

    GogglesDb::City.find_by(id: cookies[:city_id]) ||
      GogglesDb::City.new(
        name: cookies[:city_name] || cookies[:city_label],
        area: cookies[:city_area],
        country_code: cookies[:city_country_code]
      )
  end

  # Always returns the list of last season IDs, either recomputed or collected from cookies.
  # The stored cookie shall expire at browser session (each time the user closes the browser).
  #
  def last_season_ids
    # Last Seasons member variables won't change frequently, so we store them:
    return JSON.parse(cookies[:last_seasons_ids]) if cookies[:last_seasons_ids].present?

    start = Time.zone.now # compute elapsed time
    # Retrieve any available latest season(s) by type, but include also those *having* at least some results
    # (this is required by many features):
    @last_seasons_ids = GogglesDb::LastSeasonId.all.map(&:id)
    @last_seasons = GogglesDb::Season.unscoped.where(id: @last_seasons_ids)
    # [!!!] References to@last_season_ids in specs & features - CHECK & UPDATE ALSO:
    # - features/step_definitions/calendars/calendars_steps.rb:16
    # - features/step_definitions/calendars/given_any_calendars_steps.rb:10:42:65
    # - features/step_definitions/devise/given_any_user_steps.rb:105:191:240
    # - spec/support/shared_team_managers_context.rb:4

    Rails.logger.info("\r\n\r\n----> @last_seasons_ids recomputed. Elapsed time: #{Time.zone.now - start}")
    # Prevent recompute on each page load:
    cookies[:last_seasons_ids] = @last_seasons_ids.to_json
    @last_seasons_ids
  end
  #-- -------------------------------------------------------------------------
  #++
end
