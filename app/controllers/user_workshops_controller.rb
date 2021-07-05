# frozen_string_literal: true

# = UserWorkshopsController
#
class UserWorkshopsController < ApplicationController
  # Show the details page
  # == Params
  # - :id, required
  def show
    @user_workshop = GogglesDb::UserWorkshop.where(id: user_workshop_params[:id]).first
    if @user_workshop.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @user_workshop_events = @user_workshop.event_types
  end

  protected

  # Strong parameters checking
  def user_workshop_params
    params.permit(:id)
  end
end
