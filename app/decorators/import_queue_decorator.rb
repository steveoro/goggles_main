# frozen_string_literal: true

# = ImportQueueDecorator
#
class ImportQueueDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  attr_accessor :req, :solved

  # Parses the JSON data stored in this instance and sets the #req & #solved members.
  def parse_data
    @req, @solved = begin
      [
        ActiveSupport::JSON.decode(request_data),
        ActiveSupport::JSON.decode(solved_data)
      ]
    rescue ActiveSupport::JSON.parse_error
      nil
    end
  end

  # Returns the ISO date from #created_at
  def creation_date
    updated_at.to_date.to_s
  end

  # Returns the target entity name
  def target_entity
    parse_data if req.nil?
    req['target_entity']
  end

  # Safe-getter for the associated Swimmer label (if there's one set in the request).
  def swimmer_label
    parse_data if req.nil?
    req['swimmer']&.fetch('label', nil)
  end

  # Safe-getter for the associated EventType label (if there's one set in the request).
  def event_type_label
    parse_data if req.nil?
    @event_type_label ||= GogglesDb::EventType.find_by_id(req['event_type_id'])&.label
  end

  # Safe getter for the details rows.
  # Returns the details array or an empty list if the details are missing
  def details
    parse_data if req.nil?
    req['details'] || []
  end

  # Returns the a bespoke text label describing this row, depending on the
  # group UID.
  def text_label
    parse_data if req.nil?
    case uid
    when 'chrono'
      "⏱ x#{details.count} #{event_type_label}, #{swimmer_label}"
    when 'res'
      "📌 x#{details.count} by #{user.name}"
    else
      "#{target_entity} by #{user.name}"
    end
  end
end
