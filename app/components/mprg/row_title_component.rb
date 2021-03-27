# frozen_string_literal: true

#
# = Mprg components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Mprg
  #
  # = Mprg::RowTitleComponent
  #
  # Renders the MeetingProgram title as sub-table row (+tr+).
  #
  # - DOM ID: "mprg-#{meeting_program.id}"
  #
  class RowTitleComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting_program: an undecorated GogglesDb::MeetingProgram model instance
    def initialize(meeting_program:)
      super
      @meeting_program = meeting_program
    end

    # Skips rendering unless the member is properly set
    def render?
      @meeting_program.instance_of?(GogglesDb::MeetingProgram)
    end

    protected

    # Returns the DOM ID for this component
    def dom_id
      "mprg-#{@meeting_program&.id}-#{@meeting_program&.category_type_id}-#{@meeting_program&.gender_type_id}"
    end

    # Returns the title bar style classes depending on the MeetingProgram type
    def style_classes
      return 'bg-success text-light sticky-header' if @meeting_program.relay?

      'bg-info text-light sticky-header'
    end
  end
end
