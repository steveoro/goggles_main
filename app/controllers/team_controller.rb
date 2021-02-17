# frozen_string_literal: true

# = TeamController
#
class TeamController < ApplicationController
  # Show Team details
  # == Params
  # - :id, required
  def show
    @team = GogglesDb::Team.find_by(id: params.permit(:id)[:id])
  end
end
