# frozen_string_literal: true

require 'singleton'

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Solver singleton factory
  #
  #   - version:  7-0.3.41
  #   - author:   Steve A.
  #
  # Allows to create strategy objects for solving ("creating") new required
  # entities from micro-transactions requests.
  #
  # See GogglesDb::ImportQueue for more info.
  #
  class Factory
    include Singleton

    # Returns a dedicated strategy instance depending on the specified target entity name.
    #
    # It never returns +nil+; raises an error in case of a requested target entity which doesn't
    # have a Solver class.
    #
    # When successful, the returning strategy shall try to fill-in the gaps for all required
    # associations and shan't consider its task as "solved" as long as the resulting target
    # instance can be safely validated & saved.
    #
    # == Params:
    # - target_entity_name: simplified string name of the model class to be solved (without any namespace).
    # - req: Hash of request attributes typically parsed from the JSON request data stored
    #        in an ImportQueue row
    # - default: possible default value used only in case the solver strategy resolves to nil (defaults to +nil+)
    #
    # === Support notes:
    # No update, no deletion, only retrieval & creation.
    #
    # Quite implicitly, "solving" ImportQueues is all about finding or creating ("importing")
    # new objects; definitely, not *deleting* or *updating* them.
    #
    # In other words, depending on the implementation of each finder (tipically, a WHERE clause of some kind),
    # the solver may return a row having the same required base bindings but slightly different values from
    # all the other (unrequired) request attributes.
    #
    # In a few cases, the finder may yield a +nil+ to issue a conflict that can then be manually resolved
    # by using the Admin2 front-end or even be resolved automatically by giving priority to the object that
    # has similar data but with more solved bindings in it.
    # (In the #init_bindings implementation, using root_key?(<BINDING_NAME>) may be useful to determine if
    # the request has data at the root level or in a nested hash.)
    #
    # In some specific cases (currently only for Lookup entities), the solver may return directly the default
    # value specified (as +default+ param) in case the finder strategy yields nothing.
    #
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    def self.for(target_entity_name, req, default = nil)
      case target_entity_name
      when 'Badge'
        Badge.new(req:)
      when 'CategoryType'
        CategoryType.new(req:)
      when 'City'
        City.new(req:)
      when 'Lap'
        Lap.new(req:)

      when 'DayPartType', 'DisqualificationCodeType',
           'EditionType', 'EntryTimeType', 'EventType', 'GenderType',
           'HeatType',
           'PoolType', 'SeasonType', 'StrokeType', 'TimingType'
        LookupEntity.new(req:, target_name: target_entity_name, default:)

      when 'MeetingEvent'
        MeetingEvent.new(req:)
      when 'MeetingIndividualResult'
        MeetingIndividualResult.new(req:)
      when 'MeetingProgram'
        MeetingProgram.new(req:)
      when 'MeetingRelayResult'
        MeetingRelayResult.new(req:)
      when 'MeetingRelaySwimmer'
        MeetingRelaySwimmer.new(req:)
      when 'MeetingSession'
        MeetingSession.new(req:)
      when 'Meeting'
        Meeting.new(req:)
      when 'Season'
        Season.new(req:)
      when 'Swimmer'
        Swimmer.new(req:)
      when 'SwimmingPool'
        SwimmingPool.new(req:)
      when 'TeamAffiliation'
        TeamAffiliation.new(req:)
      when 'Team'
        Team.new(req:)
      when 'UserLap'
        UserLap.new(req:)
      when 'UserResult'
        UserResult.new(req:)
      when 'UserWorkshop'
        UserWorkshop.new(req:)

      else
        raise(ArgumentError, "New, unsupported or unimplemented target requested (#{target_entity_name}).")
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  end
end
