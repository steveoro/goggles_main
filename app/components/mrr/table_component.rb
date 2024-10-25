# frozen_string_literal: true

#
# = MRR components module
#
#   - version:  7-0.7.23
#   - author:   Steve A.
#
module MRR
  #
  # = MRR::TableComponent
  #
  # Collapsible table for MRR list/association data display.
  #
  class TableComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - mrrs: the GogglesDb::MeetingRelayResult relation holding the list of MRRs to be displayed
    # - managed_team_ids: array of integer Team IDs that can be "managed" by the current user;
    #                     a +nil+ value will disable the rendering check for the action buttons.
    # - user_teams: array of Team instances to which the current user belongs, if any; an empty array otherwise;
    #               note that this parameter should never be +nil+.
    # - current_user_is_admin: this should be +true+ only when the current_user has Admin grants; +false+ otherwise.
    def initialize(mrrs:, managed_team_ids:, user_teams: [], current_user_is_admin: false) # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
      super
      @mrrs = if mrrs.is_a?(ActiveRecord::Relation) && mrrs.first.is_a?(GogglesDb::MeetingRelayResult)
                # NOTE: adding left_outer_joins to the query below will slow down the rendering significantly:
                # &.left_outer_joins(:meeting_relay_swimmers, :relay_laps)
                mrrs&.joins(:category_type, :team)
                    &.includes(:team, :category_type, :meeting,
                               meeting_relay_swimmers: %i[relay_laps])
                    &.order(minutes: :asc, seconds: :asc, hundredths: :asc)
              else
                mrrs
              end
      @mrrs_with_rank = []
      @mrrs_with_no_rank = []
      # To be included in ranking, a MRR row must have both a positive rank & timing:
      @mrrs.each do |mrr|
        mrr.rank.positive? && mrr.to_timing.positive? ? @mrrs_with_rank << mrr : @mrrs_with_no_rank << mrr
      end
      @managed_team_ids = managed_team_ids
      @user_teams = user_teams
      @current_user_is_admin = current_user_is_admin
    end

    # Skips rendering unless @mrrs is enumerable and orderable :by_timing
    def render?
      @mrrs.respond_to?(:each) && @mrrs.respond_to?(:by_timing) && @mrrs.respond_to?(:by_rank) &&
        @mrrs.respond_to?(:with_rank) && @mrrs.respond_to?(:with_no_rank)
    end

    protected

    # Returns +true+ if the specified +mrr+ row can show the "edit lap" button.
    def can_edit_lap?(mrr)
      return true if @current_user_is_admin || @managed_team_ids.nil?

      team_id = mrr.team_id if mrr.respond_to?(:team_id)
      @current_user_is_admin || @managed_team_ids.include?(team_id)
    end

    # Returns +true+ if the specified +mrr+ row can show the "report mistake" button.
    def can_report_mistake?(mrr)
      can_edit_lap?(mrr) || @user_teams.map(&:id).include?(mrr.team_id)
    end
  end
end
