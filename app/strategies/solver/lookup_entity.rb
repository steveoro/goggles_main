# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = LookupEntity solver strategy object
  #
  #   - version:  7-0.3.41
  #   - author:   Steve A.
  #
  # Tries to resolve a request for building a new GogglesDb::<ANY_LOOKUP_ENTITY>.
  #
  # Typically, all lookup entities have an +id+ and a +code+, both unique.
  #
  class LookupEntity < BaseStrategy
    # Creates a new Solver strategy.
    # Constructor will raise errors if the target_name is not a class member of GogglesDb.
    #
    # == Params:
    # - req: Hash of attributes typically parsed from the JSON request
    #         data of an ImportQueue row
    # - target_name: camelcase target name (without 'GogglesDb::')
    # - default: possible default value used only in case the solver strategy resolves to nil (defaults to +nil+)
    #
    def initialize(req:, target_name:, default: nil)
      super(req:)
      @entity_name = target_name.tableize.singularize
      @entity_class = GogglesDb.module_eval(target_name)
      @default = default
    end

    # Returns the first entity row found that matches the finder criteria.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. code: matched by equality
    # 3. default value: matched by equality with 'id'
    #
    def finder_strategy
      id = value_from_req(key: "#{@entity_name}_id", nested: @entity_name, sub_key: 'id')
      code = value_from_req(key: "#{@entity_name}_code", nested: @entity_name, sub_key: 'code')

      if id.to_i.positive?
        @entity_class.find_by(id:)
      elsif code
        @entity_class.find_by(code:)
      elsif @default.present?
        @entity_class.find_by(id: @default)
      end
    end
  end
end
