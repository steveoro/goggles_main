# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = MeetingRelaySwimmer solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::MeetingRelaySwimmer.
  #
  class MeetingRelaySwimmer < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'meeting_relay_swimmer_id', nested: 'meeting_relay_swimmer', sub_key: 'id')
      # Priority #1
      return GogglesDb::MeetingRelaySwimmer.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::MeetingRelaySwimmer.where(required_bindings).first
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
      return nil unless required_bindings.values.all?(&:present?)

      new_instance = GogglesDb::MeetingRelaySwimmer.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
      new_instance.relay_order = existing_relay_order(new_instance) + 1 unless new_instance.relay_order.positive?
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
        meeting_relay_result_id: Solver::Factory.for('MeetingRelayResult', root_key?('meeting_relay_result') ? req : req['meeting_relay_swimmer']),
        stroke_type_id: Solver::Factory.for('StrokeType', root_key?('stroke_type') ? req : req['meeting_relay_swimmer']),
        # Give priority to the nested versions:
        swimmer_id: Solver::Factory.for('Swimmer', nested_key?('meeting_relay_swimmer', 'swimmer') ? req['meeting_relay_swimmer'] : req),
        badge_id: Solver::Factory.for('Badge', nested_key?('meeting_relay_swimmer', 'badge') ? req['meeting_relay_swimmer'] : req),

        # Optional fields:
        relay_order: value_from_req(key: 'relay_order', nested: 'meeting_relay_swimmer', sub_key: 'relay_order') || 0,
        reaction_time: value_from_req(key: 'meeting_relay_swimmer_reaction_time', nested: 'meeting_relay_swimmer', sub_key: 'reaction_time') || 0.0,
        minutes: value_from_req(key: 'meeting_relay_swimmer_minutes', nested: 'meeting_relay_swimmer', sub_key: 'minutes'),
        seconds: value_from_req(key: 'meeting_relay_swimmer_seconds', nested: 'meeting_relay_swimmer', sub_key: 'seconds'),
        hundredths: value_from_req(key: 'meeting_relay_swimmer_hundredths', nested: 'meeting_relay_swimmer', sub_key: 'hundredths')
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[meeting_relay_result_id stroke_type_id swimmer_id badge_id]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end

    # Returns an esteem of the existing MeetingRelaySwimmer order for the associated MeetingRelayResult,
    # if the result's already solved in the specified new instance. (It may not.)
    # Falls back to zero in the worst case.
    #
    # == Params:
    # - new_instance: the new instance constructed by the creator method.
    #                 (It doesn't have to be saved yet: it just needs a meeting_session_id set)
    #
    def existing_relay_order(new_instance)
      return 0 unless new_instance&.meeting_relay_result

      # Priorities:
      # 1. last relay order found in result
      # 2. total swimmers found count
      # 3. fallback to 0
      mrelay_result = new_instance.meeting_relay_result
      mrelay_result.meeting_relay_swimmers.by_order.last&.relay_order ||
        mrelay_result.meeting_relay_swimmers.count || 0
    end
  end
end
