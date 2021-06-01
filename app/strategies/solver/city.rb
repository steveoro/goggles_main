# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = City solver strategy object
  #
  #   - version:  7.02.18
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::City.
  #
  class City < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    # 3. name: full-text search index on #name
    #
    def finder_strategy
      id = value_from_req(key: 'city_id', nested: 'city', sub_key: 'id')
      # Priority #1
      return GogglesDb::City.find_by_id(id) if id

      # Priority #2
      solve_bindings
      if all_bindings_solved?
        return GogglesDb::City.where(
          name: @bindings[:name],
          country_code: @bindings[:country_code]
        ).first
      end

      # Priority #3
      # Assumes: first match = best match
      GogglesDb::City.for_name(@bindings[:name]).first if @bindings[:name]
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns a newly created target entity instance if all the bindings were solved
    # and the row could be saved.
    # Returns +nil+ when not found.
    def creator_strategy
      solve_bindings
      return nil unless all_bindings_solved?

      new_instance = GogglesDb::City.new
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
    def init_bindings
      @bindings = {
        name: value_from_req(key: 'city_name', nested: 'city', sub_key: 'name'),
        country_code: value_from_req(key: 'city_country_code', nested: 'city', sub_key: 'country_code')
      }
    end
  end
end
