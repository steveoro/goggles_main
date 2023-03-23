# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = MeetingRelayResult solver strategy object
  #
  #   - version:  7-0.3.41
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::MeetingRelayResult.
  #
  class MeetingRelayResult < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'meeting_relay_result_id', nested: 'meeting_relay_result', sub_key: 'id')
      # Priority #1
      return GogglesDb::MeetingRelayResult.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::MeetingRelayResult.where(required_bindings).first
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

      new_instance = GogglesDb::MeetingRelayResult.new
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
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    def init_bindings
      @bindings = {
        meeting_program_id: Solver::Factory.for('MeetingProgram', root_key?('meeting_program') ? req : req['meeting_relay_result']),
        # Give priority to the nested version of Swimmer & Team:
        team_id: Solver::Factory.for('Team', nested_key?('meeting_relay_result', 'team') ? req['meeting_relay_result'] : req),
        team_affiliation_id: Solver::Factory.for(
          'TeamAffiliation',
          nested_key?('meeting_relay_result', 'team_affiliation') ? req['meeting_relay_result'] : req
        ),
        # Needed to discriminate between different relays from same team:
        relay_code: value_from_req(
          key: 'relay_code',
          nested: 'meeting_relay_result', sub_key: 'relay_code'
        ),

        # Optional fields:
        rank: value_from_req(
          key: 'meeting_relay_result_rank',
          nested: 'meeting_relay_result', sub_key: 'rank'
        ) || 0,
        reaction_time: value_from_req(
          key: 'meeting_relay_result_reaction_time',
          nested: 'meeting_relay_result', sub_key: 'reaction_time'
        ) || 0.0,

        minutes: value_from_req(
          key: 'meeting_relay_result_minutes',
          nested: 'meeting_relay_result', sub_key: 'minutes'
        ) || 0,
        seconds: value_from_req(
          key: 'meeting_relay_result_seconds',
          nested: 'meeting_relay_result', sub_key: 'seconds'
        ) || 0,
        hundredths: value_from_req(
          key: 'meeting_relay_result_hundredths',
          nested: 'meeting_relay_result', sub_key: 'hundredths'
        ) || 0,

        standard_points: value_from_req(
          key: 'meeting_relay_result_standard_points',
          nested: 'meeting_relay_result', sub_key: 'standard_points'
        ) || 0,
        meeting_points: value_from_req(
          key: 'meeting_relay_result_meeting_points',
          nested: 'meeting_relay_result', sub_key: 'meeting_points'
        ) || 0,

        entry_time_type_id: Solver::Factory.for(
          'EntryTimeType',
          root_key?('entry_time_type') ? req : req['meeting_relay_result'],
          GogglesDb::EntryTimeType::LAST_RACE_ID
        ),
        disqualification_code_type_id: Solver::Factory.for(
          'DisqualificationCodeType',
          root_key?('disqualification_code_type') ? req : req['disqualification_code_type']
        )
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[meeting_program_id team_affiliation_id team_id relay_code]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
