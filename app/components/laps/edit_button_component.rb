# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7-0.4.25
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::EditButtonComponent
  #
  # Makes an XHR request for rendering the modal dialog with the edit form
  # tailored for AbstractLaps.
  #
  class EditButtonComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>parent_result</tt>: a valid instance of an associated parent <tt>GogglesDb::AbstractResult</tt>.
    #   must be already serialized (not new)
    #
    # - <tt>can_manage</tt>: master flag to enable the rendering of the component; default: false
    #
    def initialize(parent_result:, can_manage: false)
      super
      @parent_result = parent_result
      @can_manage = can_manage
    end

    # Skips rendering unless the required parameters are set
    def render?
      @can_manage && @parent_result.is_a?(GogglesDb::AbstractResult)
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
