# frozen_string_literal: true

# = MeetingDecorator
#
class MeetingDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation also for methods added to the AR::Relation by Kaminari
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the link to #show using the description as link label.
  #
  def link_to_full_name
    h.link_to(decorated.display_label, h.meeting_show_path(id: object.id))
  end

  private

  # Returns the decorated base object instance, memoized.
  def decorated
    # object.decorate is missing :season_type from default scope, so we retrieve it manually:
    @decorated ||= GogglesDb::Meeting.includes(:edition_type, :meeting_sessions, :meeting_individual_results, season: [:season_type])
                                     .find_by(id: object.id)
                                     .decorate
  end
end
