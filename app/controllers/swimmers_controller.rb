# frozen_string_literal: true

# = SwimmersController
#
class SwimmersController < ApplicationController
  # Show Swimmer details. AKA: Swimmer radiography or dashboard.
  # == Params
  # - :id, required
  def show
    @swimmer = GogglesDb::Swimmer.find_by(id: swimmer_params[:id])
    return unless @swimmer.nil?

    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end

  protected

  # /show action strong parameters checking
  def swimmer_params
    params.permit(:id)
  end
end
