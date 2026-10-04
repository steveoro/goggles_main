# frozen_string_literal: true

# = TrainingsController
#
# "Creative trainings" (it: 'Allenamenti Creativi') photo gallery.
# Rows are created & managed remotely by operators using goggles_admin2 through
# the goggles_api v3 /training endpoints; this action only renders them.
#
class TrainingsController < ApplicationController
  # This page is gated by user login:
  before_action :authenticate_user!

  # Number of gallery thumbnails shown per page:
  PER_PAGE = 24

  # [GET] '/creative_trainings' gallery grid.
  def index
    @trainings = GogglesDb::Training.with_picture
                                    .includes(:swimmer, picture_attachment: :blob)
                                    .by_date(:desc)
                                    .page(params[:page]).per(PER_PAGE)

    # Data consumed by the Stimulus 'gallery' controller for the full-size modal:
    @gallery_items = @trainings.map do |training|
      {
        full_url: rails_blob_path(training.picture),
        title: training.title,
        training_by: training.training_by,
        created_by: training.created_by,
        swimmer_url: training.swimmer.present? ? swimmer_show_path(training.swimmer_id) : nil,
        description: training.description
      }
    end
  end
end
