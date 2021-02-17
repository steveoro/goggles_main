# frozen_string_literal: true

# = MeetingController
#
class MeetingController < ApplicationController
  # Show Meeting details
  # == Params
  # - :id, required
  def show
    @team = GogglesDb::Meeting.find_by(id: params.permit(:id)[:id])
  end
end
