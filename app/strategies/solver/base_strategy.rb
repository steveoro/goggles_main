# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = BaseStrategy parent object
  #
  #   - version:  7.02.18
  #   - author:   Steve A.
  #
  # Encapsulates the base interface for its siblings.
  #
  # == Needed overrides/implementations:
  # For each sibling class:
  #
  # 1. init_bindings: define the Hash of all possible field/association bindings that have
  #    to be resolved;
  #
  # 2. finder_strategy: if the resolved target entity should be found among existing rows;
  #
  # 3. creator_strategy: if the resolved target entity should be created from the supplied values
  #    found from the set bindings (optional).
  #
  # Note that, by design, the bindings won't even be set if the request is empty.
  #
  class BaseStrategy
    # Target model instance getter
    attr_reader :entity

    # Target attributes Hash (allegedly, coming from a parsed ImportQueue request)
    attr_reader :req

    # Target bindings list
    attr_reader :bindings

    # Creates a new Solver strategy.
    #
    # == Params:
    # - req: Hash of attributes typically parsed from the JSON request
    #         data of an ImportQueue row
    #
    def initialize(req: {})
      @req = req
      @bindings = {}
      # Perform also the overridden bindings setup only if we actually have a request:
      init_bindings if req.present?
    end

    # Makes sure there aren't any solver strategies left in the bindings.
    # When this is +true+, it implies that all bound entity associations or
    # attribute values have been already set, are existing and solved.
    def all_bindings_solved?
      bindings.none? { |_k, solver| solver.nil? || solver.is_a?(Solver::BaseStrategy) }
    end

    # Returns the list of bindings that have been successfully set.
    def bindings_solved
      bindings.reject { |_k, solver| solver.nil? || solver.is_a?(Solver::BaseStrategy) }
    end

    # Returns the list of bindings that have not been solved yet.
    def bindings_left
      bindings.select { |_k, solver| solver.nil? || solver.is_a?(Solver::BaseStrategy) }
    end

    # Returns +true+ only if the target #entity has been set and is valid.
    def solved?
      entity&.valid? || false
    end

    # Tries to "solve" the requested target by finding the row referred by the attributes
    # or by creating a new one, if all the required values are given or already solved.
    #
    # This uses a dual-strategy approach:
    # 1. finder: find any already existing row
    # 2. creator: create a new one if it's possible and the first strategy failed
    #
    # == Returns
    # The target entity ID when successful setting also the #entity member.
    # Returns +nil+ setting also #entity to +nil+ when unsuccessful.
    #
    # === Note:
    # To enable either the finder or the creator strategies in siblings, you'll need to
    # override them with an actual implementation.
    #
    def solve!
      # 1) Finder: solves when existing & found
      @entity = finder_strategy

      # 2) Creator: solves when all bindings are solved and the object is valid
      @entity = creator_strategy unless solved?

      set_bindings_from_entity_if_solved
      @entity&.id
    end
    #-- -----------------------------------------------------------------------
    #++

    protected

    # Hash of required bindings, attributes or associations that have to be resolved, using format:
    #
    #     key_column_name => solver_instance || value_from_req
    #
    # A direct attribute binding will be resolved to +nil+ if can't be found inside the
    # current data set after a call to #solve!.
    #
    # ==> OVERRIDE IN SIBLINGS <==
    def init_bindings
      @bindings = {}
    end

    # Tries to solve all bindings that are set to Solver strategies.
    # Does nothing if the entity is already solved.
    def solve_bindings
      return if solved?

      @bindings.each { |key, solver| @bindings[key] = solver.solve! if solver.is_a?(BaseStrategy) }
    end

    # Forces bindings values by setting them with the entity attributes.
    # Does nothing unless the entity is solved.
    def set_bindings_from_entity_if_solved
      return unless solved?

      @bindings.each { |key, _solved| @bindings[key] = @entity.send(key) if @entity.respond_to?(key) }
    end

    # Returns true if the specified +key+ is present at root level.
    # == Params:
    # - key: both '<key>' & '<key>_id' are checked for presence
    def root_key?(key)
      req&.key?(key) || req&.key?("#{key}_id")
    end

    # Returns true if the specified +sub_key+ is present at +nested+ level.
    # == Params:
    # - nested: the name of the nested entity that may include the key
    # - sub_key: both '<sub_key>' & '<sub_key>_id' are checked for presence
    def nested_key?(nested, sub_key)
      req&.fetch(nested, nil)&.fetch(sub_key, nil) || req&.fetch(nested, nil)&.fetch("#{sub_key}_id", nil)
    end

    # Returns a value for the corresponding key, if present in the attributes.
    # Attributes for legacy reasons can store values both a root level, using the
    # specified +key+, or as a nested entity with multiple attributes, using the +nested+ key
    # as target for the value.
    #
    # Returns the value found or +nil+ using FIFO-precedence.
    #
    # == Params:
    # - key: main key for the attribute search
    # - nested: nested name for the sub-entity definition
    # - sub_key: nested sub-key for the value retrieval
    #
    def value_from_req(key:, nested:, sub_key:)
      req&.fetch(key, nil) || req&.fetch(nested, nil)&.fetch(sub_key, nil)
    end

    # Should return the first entity row found that matches at least one of the key attributes.
    # Otherwise, +nil+ when not found.
    #
    # ==> OVERRIDE IN SIBLINGS to enable usage of this strategy <==
    def finder_strategy; end

    # Should return a newly created target entity instance if all bindings were solved
    # and the row could be saved.
    # Otherwise, +nil+ when unsuccessful.
    #
    # ==> OVERRIDE IN SIBLINGS to enable usage of this strategy <==
    def creator_strategy; end
  end
end
