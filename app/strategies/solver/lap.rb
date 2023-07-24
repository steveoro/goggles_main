# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Lap solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::Lap.
  #
  class Lap < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'lap_id', nested: 'lap', sub_key: 'id')
      # Priority #1
      return GogglesDb::Lap.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::Lap.where(required_bindings).first
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

      new_instance = GogglesDb::Lap.new
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
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def init_bindings
      @bindings = {
        meeting_individual_result_id: Solver::Factory.for(
          'MeetingIndividualResult',
          root_key?('meeting_individual_result') ? req : req['lap']
        ),
        meeting_program_id: Solver::Factory.for(
          'MeetingProgram',
          root_key?('meeting_program') ? req : req['lap']
        ),
        # Give priority to the nested version of Swimmer & Team:
        swimmer_id: Solver::Factory.for('Swimmer', nested_key?('lap', 'swimmer') ? req['lap'] : req),
        team_id: Solver::Factory.for('Team', nested_key?('lap', 'team') ? req['lap'] : req),
        length_in_meters: value_from_req(key: 'lap_length_in_meters', nested: 'lap', sub_key: 'length_in_meters'),

        # Optional fields:
        reaction_time: value_from_req(key: 'lap_reaction_time', nested: 'lap', sub_key: 'reaction_time'),
        minutes: value_from_req(key: 'lap_minutes', nested: 'lap', sub_key: 'minutes'),
        seconds: value_from_req(key: 'lap_seconds', nested: 'lap', sub_key: 'seconds'),
        hundredths: value_from_req(key: 'lap_hundredths', nested: 'lap', sub_key: 'hundredths'),

        position: value_from_req(key: 'lap_position', nested: 'lap', sub_key: 'position'),
        minutes_from_start: value_from_req(
          key: 'minutes_from_start',
          nested: 'lap', sub_key: 'minutes_from_start'
        ),
        seconds_from_start: value_from_req(
          key: 'seconds_from_start',
          nested: 'lap', sub_key: 'seconds_from_start'
        ),
        hundredths_from_start: value_from_req(
          key: 'hundredths_from_start',
          nested: 'lap', sub_key: 'hundredths_from_start'
        ),

        breath_cycles: value_from_req(key: 'lap_breath_cycles', nested: 'lap', sub_key: 'breath_cycles'),
        stroke_cycles: value_from_req(key: 'lap_stroke_cycles', nested: 'lap', sub_key: 'stroke_cycles'),
        underwater_seconds: value_from_req(
          key: 'lap_underwater_seconds',
          nested: 'lap', sub_key: 'underwater_seconds'
        ),
        underwater_hundredths: value_from_req(
          key: 'lap_underwater_hundredths',
          nested: 'lap', sub_key: 'underwater_hundredths'
        )
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[meeting_individual_result_id meeting_program_id swimmer_id team_id length_in_meters]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
