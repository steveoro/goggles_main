# frozen_string_literal: true

# = ImportQueueDecorator
#
class ImportQueueDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

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

  # Returns the parsed request_data
  def req
    parse_data if @req.nil?
    @req
  end

  # Returns the parsed solved_data
  def solved
    parse_data if @solved.nil?
    @solved
  end

  # Returns the target entity name
  def target_entity
    req['target_entity']
  end

  # Returns the root-level key of the request hash, according to the 'target_entity' value.
  def root_key
    target_entity&.tableize&.singularize
  end

  # Similarly to root_key, returns the first-depth parent key of the request hash according to the 'target_entity' value.
  def result_parent_key
    # TODO: GENERALIZE THIS after we process more different types of IQ
    root_key == 'user_lap' ? 'user_result' : 'meeting_individual_result'
  end

  # Safe-getter for the 'base_uid' from the #solved_data member. Returns +nil+ if not set.
  def base_uid
    solved&.fetch('base_uid', nil)
  end

  # Returns all associated ImportQueues of type 'chrono' for this instance as an ActiveRecord
  # association, excluding this instance.
  def chrono_siblings
    GogglesDb::ImportQueue.where(uid: "chrono-#{base_uid}", user_id: user_id)
  end

  # Safe-getter for the associated Swimmer label (if there's one set in the request). Returns +nil+ if not set.
  def swimmer_label
    req&.fetch(root_key, nil)&.fetch('swimmer', nil)&.fetch('complete_name', nil)
  end

  # Memoized safe-getter for the associated EventType (if there's one set in the request). Returns +nil+ if not set.
  def event_type
    event_type_id = req&.fetch(root_key, nil)&.fetch(result_parent_key, nil)&.fetch('event_type_id', nil)
    @event_type ||= GogglesDb::EventType.find_by_id(event_type_id)
  end

  # Memoized safe-getter for a display label for any timing data associated with the root_key.
  def timing_label
    timing = Timing.new(
      minutes: fetch_root_int_value('minutes'),
      seconds: fetch_root_int_value('seconds'),
      hundredths: fetch_root_int_value('hundredths')
    )
    @timing_label ||= timing.to_s
  end

  # Memoized safe-getter for the 'length_in_meters' root value, if given. Returns +nil+ if not set.
  def length_in_meters
    @length_in_meters ||= fetch_root_int_value('length_in_meters')
  end

  # Returns the a bespoke text label describing this row, depending on the
  # group UID.
  def text_label
    case uid
    when 'chrono'
      "⏱ #{event_type&.label}: #{timing_label}, #{swimmer_label}"
    when /chrono-\d+/
      "#{timing_label}, #{length_in_meters} m"
    when 'res'
      "📌 by #{user.name}"
    else
      "#{target_entity} by #{user.name}"
    end
  end

  private

  # Returns an integer value stored as a root sibling at depth 1, using +key+.
  # Defaults to 0 if not found.
  def fetch_root_int_value(key)
    req&.fetch(root_key, nil)&.fetch(key, 0).to_i
  end
end
