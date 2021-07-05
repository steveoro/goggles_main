# frozen_string_literal: true

# = MeetingsController
#
class MeetingsController < ApplicationController
  # Show the details page
  # == Params
  # - :id, required
  def show
    @meeting = GogglesDb::Meeting.where(id: meeting_params[:id]).first
    if @meeting.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @meeting_events = @meeting.meeting_events
                              .joins(:meeting_session, :event_type, :stroke_type)
                              .includes(:meeting_session, :event_type, :stroke_type)
                              .unscope(:order)
                              .order('meeting_sessions.session_order, meeting_events.event_order')
  end

  protected

  # Strong parameters checking
  def meeting_params
    params.permit(:id)
  end
end
