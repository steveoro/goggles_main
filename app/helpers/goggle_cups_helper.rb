# frozen_string_literal: true

# = GoggleCupsHelper
#
# Helper methods used by the Goggle Cup browsing/ranking views.
#
module GoggleCupsHelper
  # Returns a lambda that builds a ranking/base-timings export URL for the given +goggle_cup+.
  # Defaults to the ranking export unless a different +export_type+ is requested.
  def goggle_cup_export_lambda(goggle_cup, default_export_type: 'ranking')
    lambda { |format:, export_type: default_export_type|
      goggle_cup_ranking_path(goggle_cup, format: format, export_type: export_type)
    }
  end

  # Public path builder for a swimmer show page used by shared engine partials.
  def swimmer_show_path_for_id(swimmer_id)
    swimmer_show_path(id: swimmer_id)
  end

  # Public path builder for a meeting show page used by shared engine partials.
  def meeting_show_path_for_id(meeting_id)
    meeting_show_path(id: meeting_id)
  end
end
