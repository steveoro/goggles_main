# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = MeetingProgram solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::MeetingProgram.
  #
  class MeetingProgram < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'meeting_program_id', nested: 'meeting_program', sub_key: 'id')
      # Priority #1
      return GogglesDb::MeetingProgram.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::MeetingProgram.where(required_bindings).first
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

      new_instance = GogglesDb::MeetingProgram.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
      new_instance.event_order = existing_event_order(new_instance) + 1 unless new_instance.event_order.positive?
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
        meeting_event_id: Solver::Factory.for('MeetingEvent', root_key?('meeting_event') ? req : req['meeting_program']),
        # Get the pool_type from the meeting session when it is nested:
        pool_type_id: Solver::Factory.for('PoolType', root_key?('pool_type') ? req : req['meeting_program']),
        category_type_id: Solver::Factory.for('CategoryType', root_key?('category_type') ? req : req['meeting_program']),
        gender_type_id: Solver::Factory.for('GenderType', root_key?('gender_type') ? req : req['meeting_program']),

        # Fields w/ defaults:
        event_order: value_from_req(key: 'event_order', nested: 'meeting_program', sub_key: 'event_order') || 0,
        # NOTE: the following assumes most of the stored events will be referring to the Italy/Germany/Sweden
        #       time zone (which is still true as of 2021):
        begin_time: value_from_req(key: 'begin_time', nested: 'meeting_program', sub_key: 'begin_time') ||
                    Time.now.in_time_zone('Europe/Rome').to_s

        # Optional fields: TODO
        # time_standard_id: Solver::Factory.for('TimeStandard', root_key?('time_standard') ? req : req['meeting_program']),
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      @bindings.select do |key, _value|
        %i[meeting_event_id pool_type_id category_type_id gender_type_id].include?(key)
      end
    end

    # Returns an esteem of the existing MeetingProgram order for the associated MeetingEvent,
    # if the event is already solved in the specified new instance. (It may not.)
    # Falls back to zero in the worst case.
    #
    # == Params:
    # - new_instance: the new MeetingProgram instance constructed by the creator method.
    #                 (It doesn't have to be saved yet: it just needs a meeting_event_id set)
    #
    def existing_event_order(new_instance)
      return 0 unless new_instance&.meeting_event

      # Priorities:
      # 1. last event order found in session
      # 2. total events found count
      # 3. fallback to 0
      mevent = new_instance.meeting_event
      mevent.meeting_programs.order(:event_order).last&.event_order ||
        mevent.meeting_programs.count || 0
    end
  end
end
