# frozen_string_literal: true

#
# = MIR components module
#
#   - version:  7-0.4.25
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
    # - mirs: the GogglesDb::MeetingIndividualResult relation holding the list of MIRs to be displayed
    # - managed_team_ids: array of integer Team IDs that can be "managed" by the current user;
    #                     a +nil+ value will disable the rendering check for the action buttons.
    # - current_swimmer_id: current_user.swimmer_id value, if any.
    def initialize(mirs:, managed_team_ids:, current_swimmer_id:)
      super
      @mirs = mirs
      @managed_team_ids = managed_team_ids
      @current_swimmer_id = current_swimmer_id
    end

    # Skips rendering unless @mirs is enumerable and orderable :by_timing
    def render?
      @mirs.respond_to?(:each) && @mirs.respond_to?(:by_timing)
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
