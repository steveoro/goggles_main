# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = TeamAffiliation solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::TeamAffiliation.
  #
  class TeamAffiliation < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'team_affiliation_id', nested: 'team_affiliation', sub_key: 'id')
      # Priority #1
      return GogglesDb::TeamAffiliation.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::TeamAffiliation.where(required_bindings).first
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

      new_instance = GogglesDb::TeamAffiliation.new
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
        name: value_from_req(key: 'team_affiliation_name', nested: 'team_affiliation', sub_key: 'name') ||
              value_from_req(key: 'team_name', nested: 'team', sub_key: 'name'),
        number: value_from_req(key: 'team_affiliation_number', nested: 'team_affiliation', sub_key: 'number'),
        team_id: Solver::Factory.for('Team', root_key?('team') ? req : req['team_affiliation']),
        season_id: Solver::Factory.for('Season', root_key?('season') ? req : req['team_affiliation'])
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[name team_id season_id]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
