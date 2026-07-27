# frozen_string_literal: true

#
# = Laps components module
#
#   - version:  7-0.6.20
#   - author:   Steve A.
#
module Laps
  #
  # = Laps::TableRowComponent
  #
  # => Suitable for *any* AbstractLap <=
  #
  # Table row (tr) for lap data display.
  #
  # Visibility is controlled by the parent Laps::TableComponent tbody collapse wrapper.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - lap: the GogglesDb::Lap model instance to be displayed
    def initialize(lap:)
      @lap = lap
    end

    # Skips rendering unless the lap instance is properly set
    def render?
      @lap.class.ancestors.include?(GogglesDb::AbstractLap)
    end
  end
end
