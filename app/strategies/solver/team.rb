# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Team solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::Team.
  #
  class Team < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    # 3. name: full-text search index on #name, FIFO order
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'team_id', nested: 'team', sub_key: 'id')
      # Priority #1
      return GogglesDb::Team.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      # Don't care if all the bindings are solved given that city_id is optional:
      if @bindings[:name].present?
        return GogglesDb::Team.where(
          name: @bindings[:name],
          city_id: @bindings[:city_id]
        ).first
      end

      # Priority #3
      # Assumes: first match = best match
      GogglesDb::Team.for_name(@bindings[:name]).first if @bindings[:name]
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
      # (city_id is optional)
      return nil if @bindings[:name].blank?

      new_instance = GogglesDb::Team.new
      bindings.each { |key, solved| new_instance.send(:"#{key}=", solved) unless solved.nil? }
      new_instance.editable_name = @bindings[:name] if new_instance.editable_name.blank?
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
        name: value_from_req(key: 'team_name', nested: 'team', sub_key: 'name'),
        city_id: Solver::Factory.for('City', root_key?('city') ? req : req['team'])
      }
    end
  end
end
