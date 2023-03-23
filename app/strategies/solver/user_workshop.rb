# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = UserWorkshop solver strategy object
  #
  #   - version:  7-0.3.41
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
      return nil if @bindings.empty?

      id = value_from_req(key: 'user_workshop_id', nested: 'user_workshop', sub_key: 'id')
      # Priority #1
      return GogglesDb::UserWorkshop.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      return nil unless required_bindings.values.all?(&:present?)

      GogglesDb::UserWorkshop.where(required_bindings).first
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

      new_instance = GogglesDb::UserWorkshop.new
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
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def init_bindings
      meeting_description = value_from_req(key: 'user_workshop_description', nested: 'user_workshop', sub_key: 'description')
      @bindings = {
        description: meeting_description,
        # User id must always be supplied, cannot be found or created:
        user_id: value_from_req(key: 'user_workshop_user_id', nested: 'user_workshop', sub_key: 'user_id'),
        team_id: Solver::Factory.for('Team', root_key?('team') ? req : req['user_workshop']),
        season_id: Solver::Factory.for('Season', root_key?('season') ? req : req['user_workshop']),

        # Fields w/ defaults:
        header_date: value_from_req(key: 'header_date', nested: 'user_workshop', sub_key: 'header_date') ||
                     Time.zone.today.to_s,
        edition: value_from_req(key: 'edition', nested: 'user_workshop', sub_key: 'edition') ||
                 Time.zone.today.year.to_s,
        edition_type_id: Solver::Factory.for(
          'EditionType',
          root_key?('edition_type') ? req : req['user_workshop'],
          GogglesDb::EditionType::YEARLY_ID
        ),
        timing_type_id: Solver::Factory.for(
          'TimingType',
          root_key?('timing_type') ? req : req['user_workshop'],
          GogglesDb::TimingType::MANUAL_ID
        ),
        header_year: value_from_req(key: 'header_year', nested: 'user_workshop', sub_key: 'header_year') ||
                     Time.zone.today.year.to_s,
        code: value_from_req(key: 'user_workshop_code', nested: 'user_workshop', sub_key: 'code') ||
              normalize_string_name_into_code(meeting_description),
        confirmed: value_from_req(key: 'confirmed', nested: 'user_workshop', sub_key: 'confirmed') ||
                   true,

        # Truly optional fields:
        swimming_pool_id: Solver::Factory.for('SwimmingPool', root_key?('swimming_pool') ? req : req['user_workshop'])
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    # Filtered hash of minimum required field bindings
    def required_bindings
      required_keys = %i[description user_id team_id season_id]
      @bindings.select { |key, _value| required_keys.include?(key) }
    end
  end
end
