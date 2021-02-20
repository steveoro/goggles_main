# frozen_string_literal: true

require 'version'

# = ApplicationController
#
# Common parent controller
class ApplicationController < ActionController::Base
  before_action :detect_device_variant, :check_maintenance_mode

  private

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

  # Checks if maintenance mode is enbled, redirecting to the maintenance page.
  def check_maintenance_mode
    # Allow only legit requests while avoiding infinite redirect loop:
    if GogglesDb::AppParameter.maintenance? && (params[:controller] != 'maintenance')
      redirect_to maintenance_path
    elsif !GogglesDb::AppParameter.maintenance? && (params[:controller] == 'maintenance')
      redirect_to root_path
    end
  end
end
