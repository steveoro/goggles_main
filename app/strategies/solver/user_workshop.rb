# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = UserWorkshop solver strategy object
  #
  #   - version:  7.02.18
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::UserWorkshop.
  #
  class UserWorkshop < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      id = value_from_req(key: 'user_workshop_id', nested: 'user_workshop', sub_key: 'id')
      # Priority #1
      return GogglesDb::UserWorkshop.find_by_id(id) if id

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::UserWorkshop.where(required_bindings).first
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns a newly created target entity instance if all the bindings were solved
    # and the row could be saved.
    # Returns +nil+ when not found.
    def creator_strategy
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      new_instance = GogglesDb::UserWorkshop.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) }
      return nil unless new_instance.valid?

      new_instance.save!
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
        description: value_from_req(key: 'user_workshop_description', nested: 'user_workshop', sub_key: 'description'),
        # User id must always be supplied, cannot be found or created:
        user_id: value_from_req(key: 'user_workshop_user_id', nested: 'user_workshop', sub_key: 'user_id'),
        team_id: Solver::Factory.for('Team', root_key?('team') ? req : req['user_workshop']),
        season_id: Solver::Factory.for('Season', root_key?('season') ? req : req['user_workshop']),
        header_date: value_from_req(key: 'header_date', nested: 'user_workshop', sub_key: 'header_date') || Date.today.to_s,

        # Fields w/ defaults:
        edition: value_from_req(key: 'edition', nested: 'user_workshop', sub_key: 'edition') || 0,
        edition_type_id: Solver::Factory.for('EditionType', root_key?('edition_type') ? req : req['user_workshop']),
        timing_type_id: Solver::Factory.for('TimingType', root_key?('timing_type') ? req : req['user_workshop']),
        # Optional fields:
        header_year: value_from_req(key: 'header_year', nested: 'user_workshop', sub_key: 'header_year') || Date.today.year.to_s,
        code: value_from_req(key: 'user_workshop_code', nested: 'user_workshop', sub_key: 'code'),
        swimming_pool_id: Solver::Factory.for('SwimmingPool', root_key?('swimming_pool') ? req : req['user_workshop'])
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      @bindings.select do |key, _value|
        %i[description user_id team_id season_id header_date].include?(key)
      end
    end

    # Filtered hash of optional field bindings
    def optional_bindings
      @bindings.select do |key, _value|
        %i[edition_type_id timing_type_id header_year code swimming_pool_id].include?(key)
      end
    end
  end
end
