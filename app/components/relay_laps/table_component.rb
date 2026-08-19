# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.7.23
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::TableComponent
  #
  # Collapsible table body (+tbody+) for relay lap data display
  # (both MRSs & RelayLaps).
  #
  # - collapse DOM ID: "laps-show<MRR_id>"
  #   (typically, to be triggered by an external component)
  #
  class TableComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - relay_swimmer: the GogglesDb::MeetingRelaySwimmer relation holding the list of laps to be displayed
    # - parent_result_id: the parent MRR id, used to build the DOM ID when relay_swimmers are JsonRows
    def initialize(relay_swimmers:, parent_result_id: nil)
      @relay_swimmers = if relay_swimmers.respond_to?(:includes)
                          relay_swimmers.includes(:meeting)
                        else
                          relay_swimmers
                        end
      @parent_result_id = parent_result_id
    end

    # Skips rendering unless @relay_swimmers is enumerable
    def render?
      @relay_swimmers.respond_to?(:each)
    end

    protected

    # Returns the relay swimmers ordered by relay_order, whether they are an
    # ActiveRecord relation or an array of JsonRow legs.
    def ordered_relay_swimmers
      @relay_swimmers.respond_to?(:by_order) ? @relay_swimmers.by_order : @relay_swimmers.sort_by(&:relay_order)
    end

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
