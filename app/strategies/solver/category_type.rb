# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = CategoryType solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::CategoryType.
  #
  class CategoryType < BaseStrategy
    # Returns the first entity row found that matches the finder criteria.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match: code + season
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'category_type_id', nested: 'category_type', sub_key: 'id')
      # Priority #1
      return GogglesDb::CategoryType.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless all_bindings_solved?

      GogglesDb::CategoryType.where(
        code: @bindings[:code],
        season_id: @bindings[:season_id]
      ).first
    end

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
        code: value_from_req(key: 'category_type_code', nested: 'category_type', sub_key: 'code'),
        season_id: Solver::Factory.for('Season', root_key?('season') ? req : req['category_type'])
      }
    end
  end
end
