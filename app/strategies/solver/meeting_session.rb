# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = MeetingSession solver strategy object
  #
  #   - version:  7-0.4.25
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::MeetingSession.
  #
  class MeetingSession < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'meeting_session_id', nested: 'meeting_session', sub_key: 'id')
      # Priority #1
      return GogglesDb::MeetingSession.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless finder_required_bindings.values.all?(&:present?)

      # Find the first matching session for the same header date:
      # (Ignore session order because is basically never present in IQ request data)
      GogglesDb::MeetingSession.where(finder_required_bindings).first
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns a newly created target entity instance, serialized if and only if
    # all the bindings were solved and the resulting row was valid.
    #
    # == Returns:
    # - +nil+ until all required bindings are solved;
    # - a new target entity instance when done, saved successfully if valid,
    #   and yielding any validation erros as #error_messages.
    def creator_strategy
      return nil if @bindings.empty?

      solve_bindings
      return nil unless creator_required_bindings.values.all?(&:present?)

      new_instance = GogglesDb::MeetingSession.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
      new_instance.session_order = compute_session_order(new_instance.meeting) if new_instance.session_order.zero?
      new_instance.scheduled_date = Time.zone.today.to_s if new_instance.scheduled_date.blank?
      new_instance.save # Don't throw validation errors
      new_instance
    end
    #-- -----------------------------------------------------------------------
    #++

    protected

    # Hash of required bindings/associations that have to be resolved, using format:
    #
    #     key_column_name.to_sym => solver_instance || value_from_req
    #
    # A direct attribute binding will be resolved to +nil+ if can't be found inside the
    # current data set after a call to #solve!.
    #
    def init_bindings
      @bindings = {
        meeting_id: Solver::Factory.for('Meeting', root_key?('meeting') ? req : req['meeting_session']),
        # Fields w/ defaults (either here or in the creator):
        session_order: value_from_req(key: 'session_order', nested: 'meeting_session', sub_key: 'session_order'),
        scheduled_date: value_from_req(key: 'scheduled_date', nested: 'meeting_session', sub_key: 'scheduled_date'),
        description: value_from_req(key: 'meeting_session_description', nested: 'meeting_session', sub_key: 'description') ||
                     "#{I18n.t('activerecord.models.goggles_db/meeting_session')} #{Time.zone.today}",

        # Truly optional fields:
        swimming_pool_id: Solver::Factory.for('SwimmingPool', root_key?('swimming_pool') ? req : req['meeting_session']),
        day_part_type_id: Solver::Factory.for(
          'DayPartType',
          root_key?('day_part_type') ? req : req['meeting_session'],
          Time.zone.now.hour <= 12 ? GogglesDb::DayPartType::MORNING_ID : GogglesDb::DayPartType::AFTERNOON_ID
        )
      }
    end

    private

    # Filtered hash of minimum required field bindings for the finder strategy
    def finder_required_bindings
      required_keys = %i[meeting_id scheduled_date session_order]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end

    # Filtered hash of minimum required field bindings for the creator strategy
    def creator_required_bindings
      required_keys = %i[meeting_id]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end

    # Computes a possible session order assuming the specified meeting is valid
    def compute_session_order(meeting)
      return unless meeting.is_a?(GogglesDb::Meeting)

      max_value = meeting.meeting_sessions.order(:scheduled_date).last&.session_order
      max_value.to_i + 1
    end

    # Uses the current bindings to retrieve a Meeting instance with which compute the session order
    def compute_session_order_from_bindings
      meeting_id = @bindings[:meeting_id]
      compute_session_order(GogglesDb::Meeting.find_by(id: meeting_id))
    end
  end
end
