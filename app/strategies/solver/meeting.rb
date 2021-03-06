# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Meeting solver strategy object
  #
  #   - version:  7.3.05
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::Meeting.
  #
  class Meeting < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      id = value_from_req(key: 'meeting_id', nested: 'meeting', sub_key: 'id')
      # Priority #1
      return GogglesDb::Meeting.find_by_id(id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::Meeting.where(required_bindings).first
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

      new_instance = GogglesDb::Meeting.new
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
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def init_bindings
      meeting_description = value_from_req(key: 'meeting_description', nested: 'meeting', sub_key: 'description')
      @bindings = {
        description: meeting_description,
        season_id: Solver::Factory.for('Season', root_key?('season') ? req : req['meeting']),
        header_date: value_from_req(key: 'header_date', nested: 'meeting', sub_key: 'header_date') || Date.today.to_s,

        # Fields w/ defaults:
        edition: value_from_req(key: 'edition', nested: 'meeting', sub_key: 'edition') ||
                 Date.today.year.to_s,
        edition_type_id: Solver::Factory.for('EditionType', root_key?('edition_type') ? req : req['meeting']) ||
                         GogglesDb::EditionType::YEARLY_ID,
        timing_type_id: Solver::Factory.for('TimingType', root_key?('timing_type') ? req : req['meeting']) ||
                        GogglesDb::TimingType::SEMIAUTO_ID,
        header_year: value_from_req(key: 'header_year', nested: 'meeting', sub_key: 'header_year') ||
                     Date.today.year.to_s,
        code: value_from_req(key: 'meeting_code', nested: 'meeting', sub_key: 'code') ||
              normalize_string_name_into_code(meeting_description),

        # Truly optional fields:
        home_team_id: Solver::Factory.for('Team', root_key?('team') ? req : req['meeting'])
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      @bindings.select do |key, _value|
        %i[description season_id header_date].include?(key)
      end
    end
  end
end
