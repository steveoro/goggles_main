# frozen_string_literal: true

# = TeamDecorator
#
class TeamDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation also for methods added to the AR::Relation by Kaminari
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the link to /teams/show using +editable_name+ as link label.
  # NOTE: +TeamShowLinkComponent+ adds a tooltip to the link.
  #
  def link_to_full_name
    h.link_to(editable_name, h.team_show_path(id: object.id))
  end
end
