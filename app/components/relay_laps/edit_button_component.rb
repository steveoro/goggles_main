# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.6.21
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::EditButtonComponent
  #
  # Makes an XHR request for rendering the modal dialog with the edit form(s)
  # tailored for AbstractLaps (one form per lap, with separate buttons for adding new rows).
  #
  class EditButtonComponent < ViewComponent::Base
    # Creates a new ViewComponent displaying a button that will show the lap-edit modal window
    #
    # == Params
    # - <tt>:relay_result</tt>  => [required] a valid instance of the parent <tt>GogglesDb::MeetingRelayResult</tt>;
    #                               must be already serialized (not new) since the ID is needed.
    #
    # - <tt>:can_manage</tt>     => (default: false) master flag to enable the rendering of the component;
    #
    def initialize(relay_result:, can_manage: false)
      super
      @relay_result = relay_result
      @can_manage = can_manage
    end

    # Skips rendering unless the required parameters are set
    def render?
      @can_manage && @relay_result.is_a?(GogglesDb::MeetingRelayResult)
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
