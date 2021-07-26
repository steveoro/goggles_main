# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Badge solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::Badge.
  #
  class Badge < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'badge_id', nested: 'badge', sub_key: 'id')
      # Priority #1
      return GogglesDb::Badge.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::Badge.where(required_bindings).first
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

      new_instance = GogglesDb::Badge.new
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
      @bindings = {
        # Required:
        category_type_id: Solver::Factory.for('CategoryType', root_key?('category_type') ? req : req['badge']),
        team_affiliation_id: Solver::Factory.for('TeamAffiliation', root_key?('team_affiliation') ? req : req['badge']),
        team_id: Solver::Factory.for('Team', root_key?('team') ? req : req['badge']),
        swimmer_id: Solver::Factory.for('Swimmer', root_key?('swimmer') ? req : req['badge']),
        season_id: Solver::Factory.for('Season', root_key?('season') ? req : req['badge']),

        # Fields w/ defaults:
        entry_time_type_id: Solver::Factory.for('EntryTimeType', root_key?('entry_time_type') ? req : req['badge']) ||
                            GogglesDb::EntryTimeType::LAST_RACE_ID,
        number: value_from_req(key: 'badge_number', nested: 'badge', sub_key: 'number') || '?',
        # NOTE: for booleans, we cannot use +true+ as default or the condition will skip any other value found in the request.
        #       (The default is there just to prevent +nil+)
        off_gogglecup: value_from_req(key: 'badge_off_gogglecup', nested: 'badge', sub_key: 'off_gogglecup') || false,
        fees_due: value_from_req(key: 'badge_fees_due', nested: 'badge', sub_key: 'fees_due') || false,
        badge_due: value_from_req(key: 'badge_badge_due', nested: 'badge', sub_key: 'badge_due') || false,
        relays_due: value_from_req(key: 'badge_relays_due', nested: 'badge', sub_key: 'relays_due') || false
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      @bindings.select do |key, _value|
        %i[category_type_id team_affiliation_id team_id swimmer_id season_id].include?(key)
      end
    end
  end
end
