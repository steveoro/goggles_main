# frozen_string_literal: true

# = TeamsController
#
class TeamsController < ApplicationController
  # Show Team details
  # == Params
  # - :id, required
  def show
    @team = GogglesDb::Team.find_by(id: params.permit(:id)[:id])
    return unless @team.nil?

    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end
end
