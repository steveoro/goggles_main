# frozen_string_literal: true

# = MeetingStats module
#
# Container for statical views operations
#
module MeetingStats
  #
  # = Category strategy object
  #
  #   - version:  7-0.5.03
  #   - author:   Steve A.
  #
  class Category
    # Target GogglesDb::Meeting instance
    attr_reader :meeting

    # Creates a new Solver strategy.
    #
    # == Options:
    # - <tt>:meeting</tt> => target GogglesDb::Meeting instance
    #
    def initialize(options = {})
      @meeting = options[:meeting]
    end

    # TODO
  end
end
