# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7-0.5.01
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::EditButtonComponent
  #
  # Makes an XHR request for rendering the modal dialog with the edit form(s)
  # tailored for AbstractLaps (one form per lap, with separate buttons for adding new rows).
  #
  class EditButtonComponent < ViewComponent::Base
    # Creates a new ViewComponent displaying a button that will show the lap-edit modal window
    #
    # == Params
    # - <tt>:parent_result</tt>  => [required] a valid instance of an associated parent <tt>GogglesDb::AbstractResult</tt>;
    #                               must be already serialized (not new) since the ID is needed.
    #
    # - <tt>:can_manage</tt>     => (default: false) master flag to enable the rendering of the component;
    #
    # - <tt>:show_category</tt>  => (default: false) when +true+, passes the render option for displaying the category name
    #                               after the year of birth when refreshing the parent MIR component;
    #
    # - <tt>:show_team</tt> => when +true+ (default), passes the render option to the parent MIR component for
    #                               displaying the link to the team results page associated with this MIR row.
    #
    def initialize(parent_result:, can_manage: false, show_category: false, show_team: true)
      super
      @parent_result = parent_result
      @can_manage = can_manage
      @show_category = show_category
      @show_team = show_team
    end

    # Skips rendering unless the required parameters are set
    def render?
      @can_manage && @parent_result.is_a?(GogglesDb::AbstractResult)
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
