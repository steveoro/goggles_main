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
  #   - version:  7.02.18
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
    # - req: Hash of request attributes typically parsed from the JSON request data stored
    #        in an ImportQueue row
    #
    # === Notes:
    # Quite implicitly, "solving" ImportQueues is all about finding or creating ("importing")
    # new objects; definitely, not *deleting* them.
    #
    # In case an ImportQueue resolves to an already existing object, editing it is currently
    # considered a *conflict* and needs a manual resolution.
    # (There should be an Admin app front-end to manage this kind of issues.)
    # In a few cases, the conflict can be resolved automatically by giving priority to
    # the object that has similar data but with more solved bindings in it. (TODO)
    #
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    def self.for(target_entity_name, req)
      case target_entity_name
      when 'Badge'
        Badge.new(req: req)
      when 'CategoryType'
        CategoryType.new(req: req)
      when 'City'
        City.new(req: req)
      when 'Lap'
        Lap.new(req: req)

      when 'DayPartType', 'DisqualificationCodeType',
           'EditionType', 'EntryTimeType', 'EventType', 'GenderType',
           'PoolType', 'SeasonType', 'TimingType'
        LookupEntity.new(req: req, target_name: target_entity_name)

      when 'MeetingEvent'
        MeetingEvent.new(req: req)
      when 'MeetingIndividualResult'
        MeetingIndividualResult.new(req: req)
      when 'MeetingProgram'
        MeetingProgram.new(req: req)
      when 'MeetingRelayResult'
        MeetingRelayResult.new(req: req)
      when 'MeetingRelaySwimmer'
        MeetingRelaySwimmer.new(req: req)
      when 'MeetingSession'
        MeetingSession.new(req: req)
      when 'Meeting'
        Meeting.new(req: req)
      when 'Season'
        Season.new(req: req)
      when 'Swimmer'
        Swimmer.new(req: req)
      when 'SwimmingPool'
        SwimmingPool.new(req: req)
      when 'TeamAffiliation'
        TeamAffiliation.new(req: req)
      when 'Team'
        Team.new(req: req)
      when 'UserLap'
        UserLap.new(req: req)
      when 'UserResult'
        UserResult.new(req: req)
      when 'UserWorkshop'
        UserWorkshop.new(req: req)

      else
        raise(ArgumentError, "New, unsupported or unimplemented target requested (#{target_entity_name}).")
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  end
end
