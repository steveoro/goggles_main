# frozen_string_literal: true

# = SwimmerDecorator
#
class SwimmerDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the default text label describing this object.
  def text_label
    decorated.display_label
  end

  # Returns the link to /swimmers/show using the complete name as link label.
  # NOTE: +SwimmerShowLinkComponent+ adds a tooltip to the link.
  #
  def link_to_full_name
    # [Steve, 20210208] Adding a tooltip here doesn't give a good UX for the moment because
    # it needs a custom script to toggle the tooltip. (See: SwimmerShowLinkComponent)
    h.link_to(text_label, h.swimmer_show_path(id: object.id))
  end

  # Returns the link to /meetings/swimmer_results/:id using the complete name as link label.
  # NOTE: +SwimmerShowLinkComponent+ adds a tooltip to the link.
  #
  def link_to_results(meeting_id)
    h.link_to(complete_name, h.meeting_swimmer_results_path(id: meeting_id, swimmer_id: object.id))
  end

  # Returns a comma-separated string text mapping all the distinct team
  # names associated with the object row.
  #
  # Returns an empty string if no teams are available through the
  # Swimmer's badges.
  #
  # == Params
  # - max_length: truncate length for names; default: 20 (characters)
  #
  def link_to_teams(max_length = 20)
    # [Steve, 20210208] Adding a tooltip here doesn't give a good UX for the moment (see note in #link_to_full_name)
    links = associated_teams.map do |team|
      short_name = h.truncate(team.editable_name, length: max_length, separator: ' ')
      h.tag.li(h.link_to(short_name, h.team_show_path(id: team.id)))
    end
    h.tag.ul(
      links.join("\r\n").html_safe, class: 'p-0 ml-3'
    ).html_safe
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the decorated base object instance, memoized.
  def decorated
    # Force eager loading in case the source object is 'unscoped':
    @decorated ||= GogglesDb::Swimmer.includes(:gender_type).joins(:gender_type)
                                     .find_by(id: object.id)
                                     .decorate
  end
end
