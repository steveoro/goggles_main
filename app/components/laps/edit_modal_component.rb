# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7-0.4.25
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
    # - <tt>parent_result</tt>: a valid instance of an associated parent <tt>GogglesDb::AbstractResult</tt>.
    #   must be already serialized (not new)
    #
    # - <tt>add_row</tt>: when present and positive, a new row will be added to the table rendering, if
    #   and only if the overall total length is less then the result total distance.
    #
    def initialize(parent_result:)
      super
      @parent_result = parent_result
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
