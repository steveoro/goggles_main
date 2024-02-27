# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = UserResult solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::UserResult.
  #
  class UserResult < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'user_result_id', nested: 'user_result', sub_key: 'id')
      # Priority #1
      return GogglesDb::UserResult.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::UserResult.where(required_bindings).first
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

      new_instance = GogglesDb::UserResult.new
      bindings.each { |key, solved| new_instance.send(:"#{key}=", solved) unless solved.nil? }
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
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def init_bindings
      @bindings = {
        user_workshop_id: Solver::Factory.for('UserWorkshop', root_key?('user_workshop') ? req : req['user_result']),
        # User id must always be supplied, cannot be found or created:
        user_id: value_from_req(key: 'user_result_user_id', nested: 'user_result', sub_key: 'user_id'),
        # Give priority to the nested version of Swimmer & SwimmingPool:
        swimmer_id: Solver::Factory.for('Swimmer', nested_key?('user_result', 'swimmer') ? req['user_result'] : req),
        swimming_pool_id: Solver::Factory.for('SwimmingPool', nested_key?('user_result', 'swimming_pool') ? req['user_result'] : req),
        category_type_id: Solver::Factory.for('CategoryType', root_key?('category_type') ? req : req['user_result']),
        pool_type_id: Solver::Factory.for('PoolType', root_key?('pool_type') ? req : req['user_result']),
        event_type_id: Solver::Factory.for('EventType', root_key?('event_type') ? req : req['user_result']),

        # Optional fields:
        event_date: value_from_req(key: 'event_date', nested: 'user_result', sub_key: 'event_date') || Time.zone.today.to_s,
        reaction_time: value_from_req(key: 'user_result_reaction_time', nested: 'user_result', sub_key: 'reaction_time') || 0.0,
        minutes: value_from_req(key: 'user_result_minutes', nested: 'user_result', sub_key: 'minutes') || 0,
        seconds: value_from_req(key: 'user_result_seconds', nested: 'user_result', sub_key: 'seconds') || 0,
        hundredths: value_from_req(key: 'user_result_hundredths', nested: 'user_result', sub_key: 'hundredths') || 0,
        disqualification_code_type_id: Solver::Factory.for(
          'DisqualificationCodeType',
          root_key?('disqualification_code_type') ? req : req['disqualification_code_type']
        )
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[user_workshop_id user_id swimmer_id category_type_id pool_type_id event_type_id swimming_pool_id]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
