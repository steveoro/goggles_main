# frozen_string_literal: true

# = SwimmingPoolController
#
class SwimmingPoolController < ApplicationController
  # Show Swimming-pool details
  # == Params
  # - :id, required
  def show
    @team = GogglesDb::SwimmingPool.find_by(id: params.permit(:id)[:id])
  end
end
