# frozen_string_literal: true

# = ImportQueueDecorator
#
class ImportQueueDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the a text label for the processing state of this row.
  def state_flag
    return '🟢' if done? # (about to be deleted)
    return '' if process_runs.zero? # (not-yet processed => no status)
    return "▶ #{process_runs}" if process_runs.positive? # (show number of runs)
  end

  # Returns the a bespoke text label describing this row, depending on the
  # group UID.
  def text_label
    case uid
    when 'chrono'
      "⏱ #{req_event_type&.label}: #{req_timing}, #{req_swimmer_name} (#{req_swimmer_year_of_birth}) #{state_flag}"
    when /chrono-\d+/
      "#{req_timing}, #{req_length_in_meters} m #{state_flag}"
    when 'res'
      "📌 #{req_event_type&.label}: #{req_timing}, #{req_swimmer_name} by #{user.name} #{state_flag}"
    else
      "#{target_entity} by #{user.name} #{state_flag}"
    end
  end

  # Returns the associated Swimmer <tt>year_of_birth</tt> found by searching at a maximum
  # depth of 1, starting at the root-key depth (0) of the request, or +nil+ when
  # not found.
  #
  # === Supported layouts by priority:
  #
  # 1. /swimmer => <field_name>
  # 2. /<anything> => /swimmer => <field_name> (but not deeper)
  #
  def req_swimmer_year_of_birth
    return req&.fetch(root_key, nil)&.fetch('year_of_birth', nil) if root_key == 'swimmer'

    req&.fetch(root_key, nil)&.fetch('swimmer', nil)&.fetch('year_of_birth', nil)
  end
end
