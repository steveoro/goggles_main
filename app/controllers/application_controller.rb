# frozen_string_literal: true

require 'version'

# = ApplicationController
#
# Common parent controller
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :app_settings_row, :set_locale, :detect_device_variant, :check_maintenance_mode, :update_stats
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  protected

  # Memoize base app settings
  def app_settings_row
    @app_settings_row ||= GogglesDb::AppParameter.versioning_row
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
end
