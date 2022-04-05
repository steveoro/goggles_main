# frozen_string_literal: true

#
# = Title components module
#
#   - version:  7-0.3.50
#   - author:   Steve A.
#
module Title
  #
  # = Title::SwimmerShowLinkComponent
  #
  # Clickable "title" link for browsing back or to the "/show" action
  # associated with displaying the details of the entity.
  #
  class SwimmerShowLinkComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - swimmer: a valid Swimmer instance
    def initialize(swimmer:)
      super
      @swimmer = swimmer
    end

    # Skips rendering unless the member is properly set
    def render?
      @swimmer.is_a?(GogglesDb::Swimmer)
    end

    protected

    # Memoized link to the /show action, if available
    def link_to_full_name
      return '?' if @swimmer.blank?

      @link_to_full_name ||= SwimmerDecorator.decorate(@swimmer).link_to_full_name
    end
  end
end
