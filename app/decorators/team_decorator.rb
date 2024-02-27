# frozen_string_literal: true

# = TeamDecorator
#
class TeamDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation also for methods added to the AR::Relation by Kaminari
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the default text label describing this object.
  def text_label
    decorated.short_label
  end

  # Returns the link to /teams/show using +editable_name+ as link label.
  # NOTE: +TeamShowLinkComponent+ adds a tooltip to the link.
  #
  def link_to_full_name
    h.link_to(text_label, h.team_show_path(id: object.id))
  end

  # Returns the link to /meetings/team_results/:id using the complete name as link label.
  # NOTE: +TeamShowLinkComponent+ adds a tooltip to the link.
  #
  def link_to_results(meeting_id)
    h.link_to(text_label, h.meeting_team_results_path(id: meeting_id, team_id: object.id))
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the decorated base object instance, memoized.
  def decorated
    # Force eager loading:
    @decorated ||= GogglesDb::Team.includes(:city).find_by(id: object.id).decorate
  end
end
