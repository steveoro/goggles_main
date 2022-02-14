# frozen_string_literal: true

# = UserWorkshopsController
#
class UserWorkshopsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  # GET /user_workshops
  # Shows "My attended Workshops" grid.
  # Selects all the workshops created or attended by the current user,
  # Requires authentication & a valid associated swimmer.
  #
  def index
    if current_user.swimmer.blank?
      flash[:warning] = I18n.t('home.my.errors.no_associated_swimmer')
      redirect_to(root_path) && return
    end

    # FIXME: update [DB] gem for eager-loaded associations; current workaround:
    @swimmer = GogglesDb::Swimmer.includes(:gender_type).find_by(id: current_user.swimmer_id) if current_user.swimmer
    @grid = UserWorkshopsGrid.new(grid_params) do |scope|
      scope.where('(user_workshops.user_id = ?) OR (user_results.swimmer_id = ?)', current_user.id, @swimmer.id)
           .page(index_params[:page]).per(20)
    end
  end

  # Show the details page
  # == Params
  # - :id, required
  def show
    @user_workshop = GogglesDb::UserWorkshop.where(id: user_workshop_params[:id]).first
    if @user_workshop.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @user_workshop_events = @user_workshop.event_types.uniq
    @user_workshop_results = @user_workshop.user_results.includes(:event_type)
  end

  protected

  # Strong parameters checking
  def user_workshop_params
    params.permit(:id)
  end

  # /index action strong parameters checking
  def index_params
    params.permit(:page, :per_page)
  end

  # Grid filtering strong parameters checking
  def grid_params
    params.fetch(:user_workshops_grid, {})
          .permit(:descending, :order, :header_date, :meeting_name)
  end
end
