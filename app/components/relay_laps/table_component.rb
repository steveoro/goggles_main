# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.7.19
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::TableComponent
  #
  # Collapsible table body (+tbody+) for relay lap data display
  # (both MRSs & RelayLaps).
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
      @relay_swimmers = relay_swimmers&.joins(:gender_type, :event_type)
                                      &.includes(:gender_type, :event_type)
    end

    # Skips rendering unless @laps is enumerable and orderable :by_order
    def render?
      @relay_swimmers.respond_to?(:each) && @relay_swimmers.respond_to?(:by_order)
    end

    protected

    # Returns the associated parent result instance (memoized)
    def parent_result_id
      @parent_result_id ||= @relay_swimmers.first&.meeting_relay_result_id
    end

    # Returns the DOM ID for this component
    def dom_id
      "laps-show#{parent_result_id}"
    end
  end
end
