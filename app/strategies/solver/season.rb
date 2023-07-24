# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Season solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::Season.
  #
  class Season < BaseStrategy
    # Returns the first entity row found that matches at least one of the key attributes.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'season_id', nested: 'season', sub_key: 'id')
      # Priority #1
      return GogglesDb::Season.find_by(id:) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless all_bindings_solved?

      GogglesDb::Season.where(
        header_year: @bindings[:header_year],
        description: @bindings[:description],
        season_type_id: @bindings[:season_type_id]
      ).first
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
      return nil unless all_bindings_solved?

      new_instance = GogglesDb::Season.new
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
    def init_bindings
      @bindings = {
        header_year: value_from_req(key: 'season_header_year', nested: 'season', sub_key: 'header_year'),
        description: value_from_req(key: 'season_description', nested: 'season', sub_key: 'description'),
        begin_date: value_from_req(key: 'season_begin_date', nested: 'season', sub_key: 'begin_date'),
        end_date: value_from_req(key: 'season_end_date', nested: 'season', sub_key: 'end_date'),
        edition: value_from_req(key: 'season_edition', nested: 'season', sub_key: 'edition'),

        season_type_id: Solver::Factory.for('SeasonType', root_key?('season_type') ? req : req['season']),
        edition_type_id: Solver::Factory.for('EditionType', root_key?('edition_type') ? req : req['season']),
        timing_type_id: Solver::Factory.for('TimingType', root_key?('timing_type') ? req : req['season'])
      }
    end
  end
end
