# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.6.20
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::EditModalComponent
  #
  # Renders the relay swimmer & laps editing modal widget, with the content of the fields
  # already tied to the specified parent MRR / MRS.
  #
  class EditModalComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>:relay_result</tt>  => [required] a valid instance of the parent <tt>GogglesDb::MeetingRelayResult</tt>;
    #                               must be already serialized (not new) since the ID is needed.
    def initialize(relay_result:)
      super
      @relay_result = relay_result
    end

    # Skips rendering unless the required parameters are set
    def render?
      @relay_result.is_a?(GogglesDb::MeetingRelayResult)
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
