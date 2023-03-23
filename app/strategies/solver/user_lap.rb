# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = UserLap solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::UserLap.
  #
  class UserLap < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'user_lap_id', nested: 'user_lap', sub_key: 'id')
      # Priority #1
      return GogglesDb::UserLap.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::UserLap.where(required_bindings).first
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

      new_instance = GogglesDb::UserLap.new
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
        user_result_id: Solver::Factory.for('UserResult', root_key?('user_result') ? req : req['user_lap']),
        # Give priority to the nested version of Swimmer (to avoid conflicts):
        swimmer_id: Solver::Factory.for('Swimmer', nested_key?('user_lap', 'swimmer') ? req['user_lap'] : req),
        length_in_meters: value_from_req(key: 'user_lap_length_in_meters', nested: 'user_lap', sub_key: 'length_in_meters'),

        # Optional fields:
        reaction_time: value_from_req(key: 'user_lap_reaction_time', nested: 'user_lap', sub_key: 'reaction_time'),
        minutes: value_from_req(key: 'user_lap_minutes', nested: 'user_lap', sub_key: 'minutes'),
        seconds: value_from_req(key: 'user_lap_seconds', nested: 'user_lap', sub_key: 'seconds'),
        hundredths: value_from_req(key: 'user_lap_hundredths', nested: 'user_lap', sub_key: 'hundredths'),
        position: value_from_req(key: 'user_lap_position', nested: 'user_lap', sub_key: 'position'),
        minutes_from_start: value_from_req(
          key: 'minutes_from_start',
          nested: 'user_lap',
          sub_key: 'minutes_from_start'
        ),
        seconds_from_start: value_from_req(
          key: 'seconds_from_start',
          nested: 'user_lap',
          sub_key: 'seconds_from_start'
        ),
        hundredths_from_start: value_from_req(
          key: 'hundredths_from_start',
          nested: 'user_lap',
          sub_key: 'hundredths_from_start'
        )
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[user_result_id swimmer_id length_in_meters]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
