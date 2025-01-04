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

  # Returns the decorated base object instance, memoized.
  def decorated
    @decorated ||= object.decorate
  end

  # Returns an hash having, as keys, each session date as string and, as values, the array
  # of event types (as short string labels), memoized.
  #
  # === Result example:
  #   {
  #      "2024-11-30" => ["50SL", "100RA", "200DO", "50FA", "100MI", "1500SL"],
  #      "2024-12-01" => ["200RA", "50DO", "100FA", "800SL", "200MI", "100SL", "50RA", "100DO", "200FA", "400SL"]
  #    }
  #
  # == Returns
  # The Hash structured as in the example above or an empty Hash if no events are found.
  #
  def hash_of_session_dates_and_event_type_codes
    return @hash_of_session_dates_and_event_type_codes if @hash_of_session_dates_and_event_type_codes.present?

    event_list = decorated.event_list
    result_hash = {}
    event_list.each do |me|
      key_date = me.meeting_session.scheduled_date.to_s
      result_hash[key_date] ||= []
      result_hash[key_date] << me.event_type.label
    end

    @hash_of_session_dates_and_event_type_codes = result_hash
  end
end
