# frozen_string_literal: true

#
# = MIR components module
#
#   - version:  7.3.05
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
    def initialize(mirs:)
      super
      @mirs = mirs
    end

    # Skips rendering unless @mirs is enumerable and orderable :by_timing
    def render?
      @mirs.respond_to?(:each) && @mirs.respond_to?(:by_timing)
    end
  end
end
