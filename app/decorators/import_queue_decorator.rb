# frozen_string_literal: true

# = ImportQueueDecorator
#
class ImportQueueDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the a bespoke text label describing this row, depending on the
  # group UID.
  def text_label
    case uid
    when 'chrono'
      "⏱ #{req_event_type&.label}: #{req_timing}, #{req_swimmer_name}"
    when /chrono-\d+/
      "#{req_timing}, #{req_length_in_meters} m"
    when 'res'
      "📌 by #{user.name}"
    else
      "#{target_entity} by #{user.name}"
    end
  end
end
