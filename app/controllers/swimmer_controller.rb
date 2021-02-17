# frozen_string_literal: true

# = SwimmerController
#
class SwimmerController < ApplicationController
  # Show Swimmer details
  # == Params
  # - :id, required
  def show
    @swimmer = GogglesDb::Swimmer.find_by(id: params.permit(:id)[:id])
  end
end
