# frozen_string_literal: true

module Mprg
  #
  # = Mprg::LabelComponent
  #
  # Renders the full text label of a MeetingProgram
  #
  class LabelComponent < ViewComponent::Base
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

    # Inline rendering
    def call
      meeting_program_label
    end

    protected

    # Prepares the text label
    def meeting_program_label
      "#{@meeting_program&.event_type&.label} \
       #{@meeting_program&.category_type&.short_name} \
       #{@meeting_program&.gender_type&.label}"
    end
  end
end
