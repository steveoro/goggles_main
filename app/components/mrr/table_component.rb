# frozen_string_literal: true

#
# = MRR components module
#
#   - version:  7.01
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
    def initialize(mrrs:)
      super
      @mrrs = mrrs
    end

    # Skips rendering unless @mrrs is enumerable and orderable :by_timing
    def render?
      @mrrs.respond_to?(:each) && @mrrs.respond_to?(:by_timing)
    end
  end
end
