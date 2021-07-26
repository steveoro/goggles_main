# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = City solver strategy object
  #
  #   - version:  7.3.07
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
      return nil if @bindings.empty?

      id = value_from_req(key: 'city_id', nested: 'city', sub_key: 'id')
      # Priority #1
      return GogglesDb::City.find_by_id(id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      if required_bindings.values.all?(&:present?)
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

      new_instance = GogglesDb::City.new
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
      new_instance.country = new_instance.iso_attributes['country'] unless new_instance.country.present? ||
                                                                           new_instance.country_code.to_s.empty?
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
        name: value_from_req(key: 'city_name', nested: 'city', sub_key: 'name'),
        area: value_from_req(key: 'city_area', nested: 'city', sub_key: 'area'),
        country_code: value_from_req(key: 'city_country_code', nested: 'city', sub_key: 'country_code')
      }
    end

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      @bindings.select do |key, _value|
        %i[name country_code].include?(key)
      end
    end
  end
end
