# frozen_string_literal: true

# = SwimmersController
#
class SwimmersController < ApplicationController
  # Show Swimmer details
  # == Params
  # - :id, required
  def show
    @swimmer = GogglesDb::Swimmer.find_by(id: params.permit(:id)[:id])
    return unless @swimmer.nil?

    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end
end
