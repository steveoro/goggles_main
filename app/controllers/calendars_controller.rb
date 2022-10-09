# frozen_string_literal: true

# = CalendarsController
#
class CalendarsController < ApplicationController
  before_action :authenticate_user!, :verify_season_and_calendars

  # GET /meetings/:id
  # Shows "My attended Meetings" grid (just for the current user).
  # Requires authentication & a valid associated swimmer.
  #
  def season
    @calendars = GogglesDb::Calendar.where(season_id: @season.id)
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # /season action strong parameters checking
  def calendar_params
    params.permit(:id)
  end

  # Setter for @season. Checks that the specified Season ID is valid and
  # that at least a Calendar row is available for display.
  # Redirects to root_path otherwise.
  def verify_season_and_calendars
    @season = GogglesDb::Season.find_by(id: calendar_params[:id])
    return if @season.present? && GogglesDb::Calendar.exists?(season_id: @season.id)

    flash[:error] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end
end
