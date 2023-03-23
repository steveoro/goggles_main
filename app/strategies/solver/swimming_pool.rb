# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = SwimmingPool solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::SwimmingPool.
  #
  class SwimmingPool < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'swimming_pool_id', nested: 'swimming_pool', sub_key: 'id')
      # Priority #1
      return GogglesDb::SwimmingPool.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::SwimmingPool.where(required_bindings).first
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

      new_instance = GogglesDb::SwimmingPool.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
      # Compute nick_name afterwards if missing:
      if new_instance.nick_name.blank?
        new_instance.nick_name = normalize_string_name_into_code(
          "#{new_instance.city.name} #{new_instance.name} #{new_instance.pool_type.length_in_meters}"
        )
      end
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
        name: value_from_req(key: 'swimming_pool_name', nested: 'swimming_pool', sub_key: 'name'),
        city_id: Solver::Factory.for('City', root_key?('city') ? req : req['swimming_pool']),
        pool_type_id: Solver::Factory.for('PoolType', root_key?('pool_type') ? req : req['swimming_pool']),
        # Fields w/ defaults:
        nick_name: value_from_req(key: 'swimming_pool_nick_name', nested: 'swimming_pool', sub_key: 'nick_name')
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[name city_id pool_type_id]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
