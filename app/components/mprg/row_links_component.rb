# frozen_string_literal: true

#
# = Mprg components module
#
#   - version:  7.01
#   - author:   Steve A.
#
module Mprg
  #
  # = Mprg::RowLinksComponent
  #
  # Renders a sequence of links to all the categories for the MeetingProgram
  # specified as parameter.
  #
  # - linked DOM IDs: "#mprg-#{mprg.id}-#{mprg.category_type_id}-#{mprg.gender_type_id}"
  #
  class RowLinksComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - meeting_program: an undecorated GogglesDb::MeetingProgram association
    def initialize(meeting_programs:)
      super
      @meeting_programs = meeting_programs
    end

    # Skips rendering unless @meeting_programs is enumerable and filterable by where clause
    def render?
      @meeting_programs.respond_to?(:each) && @meeting_programs.respond_to?(:where)
    end
  end
end
