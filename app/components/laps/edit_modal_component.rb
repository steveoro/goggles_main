# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7-0.5.01
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::EditModalComponent
  #
  # Renders the lap adding/editing modal control, with the content of the fields already tied
  # to an existing parent AbstractResult (either a MIR or UserResult).
  #
  class EditModalComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>:parent_result</tt>  => [required] a valid instance of an associated parent <tt>GogglesDb::AbstractResult</tt>;
    #                               must be already serialized (not new) since the ID is needed.
    #
    # - <tt>:show_category</tt>  => when +true+, passes the render option for displaying the category name
    #                               after the year of birth when refreshing the parent MIR component;
    #
    # - <tt>:show_team</tt> => when +true+ (default), passes the render option to the parent MIR component for
    #                               displaying the link to the team results page associated with this MIR row.
    #
    def initialize(parent_result:, show_category: false, show_team: true)
      super
      @parent_result = parent_result
      @show_category = show_category
      @show_team = show_team
    end

    # Skips rendering unless the required parameters are set
    def render?
      @parent_result.is_a?(GogglesDb::AbstractResult)
    end
    #-- -----------------------------------------------------------------------
    #++

    protected

    # Prepares the 'title' text label for the parent result, without its timing.
    # (Assumes the parent result is already serialized.)
    def result_label
      "#{@parent_result.event_type.label} #{@parent_result.gender_type.label}"
    end

    # Memoized & generalized lap association
    def laps
      @laps ||= @parent_result.laps.by_distance
    end

    # Memoized swimmer instance
    def swimmer
      @swimmer ||= @parent_result.swimmer
    end
  end
end
