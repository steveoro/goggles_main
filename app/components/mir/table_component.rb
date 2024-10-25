# frozen_string_literal: true

#
# = MIR components module
#
#   - version:  7-0.7.19
#   - author:   Steve A.
#
module MIR
  #
  # = MIR::TableComponent
  #
  # => Suitable for *any* AbstractResult <=
  #
  # Collapsible table for MIR list/association data display.
  #
  class TableComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - mirs: the GogglesDb::MeetingIndividualResult or GogglesDb::UserResult relation holding the list of results to be displayed
    # - managed_team_ids: array of integer Team IDs that can be "managed" by the current user;
    #                     a +nil+ value will disable the rendering check for the action buttons.
    # - current_swimmer_id: current_user.swimmer_id value, if any.
    def initialize(mirs:, managed_team_ids:, current_swimmer_id:) # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
      super
      @mirs = if mirs.is_a?(ActiveRecord::Relation) && mirs.first.is_a?(GogglesDb::MeetingIndividualResult)
                # NOTE: adding left_outer_joins to the query below will slow down the rendering significantly:
                # &.left_outer_joins(laps: [:meeting_individual_result])
                mirs&.joins(:swimmer, :team, :meeting_program)
                    &.includes(:swimmer, :team, :meeting_program, laps: [:meeting_individual_result])
                    &.order(minutes: :asc, seconds: :asc, hundredths: :asc)
              elsif mirs.is_a?(ActiveRecord::Relation) && mirs.first.is_a?(GogglesDb::UserResult)
                # NOTE: adding left_outer_joins to the query below will slow down the rendering significantly:
                # &.left_outer_joins(user_laps: [:user_result])
                mirs&.joins(:user_workshop, :swimmer, season: :season_type)
                    &.includes(:swimmer, :season_type, user_laps: [:user_result])
                    &.order(minutes: :asc, seconds: :asc, hundredths: :asc)
              else
                mirs
              end
      @mirs_with_rank = []
      @mirs_with_no_rank = []
      # To be included in ranking, a MIR row must have both a positive rank & timing:
      @mirs&.each do |mir|
        mir.rank.positive? && mir.to_timing.positive? ? @mirs_with_rank << mir : @mirs_with_no_rank << mir
      end
      @managed_team_ids = managed_team_ids
      @current_swimmer_id = current_swimmer_id
    end

    # Skips rendering unless @mirs is enumerable and orderable :by_timing & :by_rank
    def render?
      @mirs.respond_to?(:each) && @mirs.respond_to?(:by_timing) && @mirs.respond_to?(:by_rank)
    end

    protected

    # Returns +true+ if the specified +mir+ row can show the "edit lap" button.
    def can_edit_lap?(mir)
      return true if @managed_team_ids.nil?

      team_id = mir.team_id if mir.respond_to?(:team_id)
      # UserWorkshop should be always managed by the team manager of the same team that created it:
      team_id = mir.parent_meeting.team_id if mir.is_a?(GogglesDb::UserResult)

      @managed_team_ids.include?(team_id)
    end

    # Returns +true+ if the specified +mir+ row can show the "report mistake" button.
    def can_report_mistake?(mir)
      can_edit_lap?(mir) || mir.swimmer_id == @current_swimmer_id
    end
  end
end
