# frozen_string_literal: true

# = SwimmingPoolsController
#
class SwimmingPoolsController < ApplicationController
  # Show Swimming-pool details
  # == Params
  # - :id, required
  def show
    @swimming_pool = GogglesDb::SwimmingPool.find_by(id: params.permit(:id)[:id])
    return unless @swimming_pool.nil?

    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end
end
