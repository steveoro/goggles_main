# frozen_string_literal: true

# = MeetingsController
#
class MeetingsController < ApplicationController
  # Show Meeting details
  # == Params
  # - :id, required
  def show
    @meeting = GogglesDb::Meeting.find_by(id: params.permit(:id)[:id])
    return unless @meeting.nil?

    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path)
  end
end
