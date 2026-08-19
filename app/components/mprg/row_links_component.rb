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
    # - meeting_program: an undecorated GogglesDb::MeetingProgram association or array
    def initialize(meeting_programs:)
      @meeting_programs = meeting_programs
    end

    # Skips rendering unless @meeting_programs is enumerable
    def render?
      @meeting_programs.respond_to?(:each)
    end

    protected

    # Returns the programs matching the given gender type, supporting both AR
    # relations and in-memory arrays.
    def programs_for(gender_type)
      if @meeting_programs.respond_to?(:where)
        @meeting_programs.where(gender_type_id: gender_type.id)
      else
        @meeting_programs.select { |mprg| mprg.gender_type_id == gender_type.id }
      end
    end
  end
end
