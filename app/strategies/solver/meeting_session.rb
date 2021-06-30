# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = MeetingSession solver strategy object
  #
  #   - version:  7.3.05
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
      id = value_from_req(key: 'meeting_session_id', nested: 'meeting_session', sub_key: 'id')
      # Priority #1
      return GogglesDb::MeetingSession.find_by_id(id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::MeetingSession.where(required_bindings).first
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
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      new_instance = GogglesDb::MeetingSession.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
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
        session_order: value_from_req(key: 'session_order', nested: 'meeting_session', sub_key: 'session_order'),
        # Fields w/ defaults:
        scheduled_date: value_from_req(key: 'scheduled_date', nested: 'meeting_session', sub_key: 'scheduled_date') ||
                        Date.today.to_s,
        description: value_from_req(key: 'meeting_session_description', nested: 'meeting_session', sub_key: 'description') ||
                     "#{I18n.t('activerecord.models.goggles_db/meeting_session')} #{Date.today}",
        # Truly optional fields:
        swimming_pool_id: Solver::Factory.for('SwimmingPool', root_key?('swimming_pool') ? req : req['meeting_session']),
        day_part_type_id: Solver::Factory.for('DayPartType', root_key?('day_part_type') ? req : req['meeting_session'])
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      @bindings.select do |key, _value|
        %i[meeting_id session_order].include?(key)
      end
    end
  end
end
