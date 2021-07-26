# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = BaseStrategy parent object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Encapsulates the base interface for its siblings.
  #
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
  #
  # == How to check for solving issues:
  # Assuming there's an ImportQueue containing a Lap recording request:
  #
  #   > iq = GogglesDb::ImportQueue.first
  #   > req = JSON.parse iq.request_data
  #   > solver = Solver::Lap.new(req: req)
  #   > solver.solve!
  #   > ap solver.solve_issues
  #
  # To pretty-print the #solve_issues Hash as string if awesome_print is not available:
  #
  #   > puts JSON.pretty_generate(solver.solve_issues)
  #
  class BaseStrategy
    # Target model instance getter
    attr_reader :entity

    # Target attributes Hash (allegedly, coming from a parsed ImportQueue request)
    attr_reader :req

    # Returns the Hash of messages returned by the solving process; empty when fully solved or not-yet processed
    attr_reader :solve_issues

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
      @solve_issues = {}
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

    # Returns the Hash of ActiveRecord error messages that may have prevented
    # the #entity from being saved.
    #
    # == Returns, depending on case:
    # - not solved yet (before #solve!) => nil
    # - solved successfully => empty
    # - unsolved due to missing or wrong data => nil
    # - unsolved due to binding errors in optional fields => Hash of AR messages,
    #   having format: { <column_name>: <localized_error_message> }
    def error_messages
      entity&.errors&.messages
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

    # Utility helper for codes/nick names.
    # Cleans the supplied text name into a more compact version
    # that we can use for almost-unique, displayable and verbose meeting
    # codes.
    # (Just for grouping them together as "belonging to the same type" of meeting/workshop/pool)
    #
    # == Returns
    # The "normalized" name string
    #
    # TODO: refactor this piece of legacy code into its own dedicated strategy object
    def normalize_string_name_into_code(name)
      # [Steve, 20170426] We use the "non-word" char code in Regexp ("\W") because it's
      # the most generic and works even for SHIFT-SPACEs and other strange mis-typings
      # made by hand by operators (in some cases "\s" is not enough)
      name.to_s
          .gsub(/\W\d{4}/iu, '')
          .gsub(%r{[\-_'`\\/:.,;]}, '')
          .gsub(/à/iu, 'a')
          .gsub(/[èé]/iu, 'e')
          .gsub(/ì/iu, 'i')
          .gsub(/ò/iu, 'o')
          .gsub(/ù/iu, 'u')
          .gsub(/\d+°?\W/iu, '')
          .gsub(/meeting|mtng|memorial|coppa\W+|trofeo\W+|finali\W|tr\W+/iu, '')
          .gsub(/sport\W?center/ui, 'sc')
          .gsub(/villaggio\W?sportivo/ui, 'vs')
          .gsub(/centro\W?sportivo/ui, 'cs')
          .gsub(/citta\W+di\W+|circolo/iu, '')
          .gsub(/team\Wasi|acsi|snp\W|dna\W/iu, '')
          .downcase.strip
          .gsub(/\W/iu, '')
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

      @bindings.each do |key, solver|
        @bindings[key] = solver.solve! if solver.is_a?(BaseStrategy)
        update_solving_issues_hash(key, solver)
      end

      # Keep only the issues that haven't been solved at the end:
      @solve_issues = @solve_issues.select { |key, _v| @bindings[key].nil? || @bindings[key].is_a?(Solver::BaseStrategy) }
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
    #-- -----------------------------------------------------------------------
    #++

    private

    # Updates the @solve_issues hash with the unsolved (nil or nested hash of keys)
    #
    # == Params:
    # - key: the currently processed @bindings key
    # - solver: the current @bindings value
    #
    # == Returns:
    # The updated @solve_issues Hash
    #
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def update_solving_issues_hash(key, solver)
      # Store both the nested hash of unsolvable bindings and nils or empty values if the solver
      # doesn't resolve to something, so that we can have a hierarchy of issues to show:
      unsolved_values = if solver.is_a?(BaseStrategy) && solver.solve_issues.present?
                          solver.solve_issues
                        elsif !solver.present?
                          solver
                        end

      if @solve_issues[key].present? && unsolved_values.is_a?(Hash)
        @solve_issues[key].merge!(unsolved_values)
      elsif !@solve_issues[key].present? && (unsolved_values.is_a?(Hash) || unsolved_values.nil?)
        @solve_issues[key] = unsolved_values
      end
      # ^^ Skip the {key => anything} case when key exists because that would overwrite the existing nested hash
      @solve_issues
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
