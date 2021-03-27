# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::TableComponent
  #
  # Collapsible table body (+tbody+) for relay lap data display.
  #
  # - collapse DOM ID: "laps<MRR_id>"
  #   (typically, to be triggered by an external component)
  #
  # === Known hack:
  # Multiple collapse rows will result having the same DOM ID.
  #
  class TableComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - relay_swimmer: the GogglesDb::MeetingRelaySwimmer relation holding the list of laps to be displayed
    def initialize(relay_swimmers:)
      super
      @relay_swimmers = relay_swimmers
    end

    # Skips rendering unless @laps is enumerable and orderable :by_order
    def render?
      @relay_swimmers.respond_to?(:each) && @relay_swimmers.respond_to?(:by_order)
    end
  end
end
