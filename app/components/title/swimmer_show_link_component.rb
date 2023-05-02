# frozen_string_literal: true

#
# = Title components module
#
#   - version:  7-0.5.02
#   - author:   Steve A.
#
module Title
  #
  # = Title::SwimmerShowLinkComponent
  #
  # Clickable "title" link for browsing back or to the specified action
  # usually associated with displaying the details of the entity (or any other
  # action filtered by the specific instance).
  #
  class SwimmerShowLinkComponent < ViewComponent::Base
    # Creates a new ViewComponent.
    # This also wraps the destination action link with a proper tooltip using the row itself.
    #
    # == Params:
    # - <tt>swimmer</tt>: a valid Swimmer instance
    #
    # - <tt>action_link_method</tt>: SwimmerDecorator helper symbol for the resulting action link;
    #                                defaults to <tt>link_to_full_name</tt>
    #
    # - <tt>link_extra_params</tt>: additional parameters for the <tt>action_link_method</tt>;
    #                               defaults to +nil+.
    def initialize(swimmer:, action_link_method: :link_to_full_name, link_extra_params: nil)
      super
      @deco_swimmer = SwimmerDecorator.decorate(swimmer) if swimmer
      @action_link_method = action_link_method
      @link_extra_params = link_extra_params
    end

    # Skips rendering unless the member is properly set
    def render?
      @deco_swimmer.is_a?(GogglesDb::Swimmer)
    end

    protected

    # Memoized link to the selected controller action; defaults to /show action.
    def link_to_action
      return '?' if @deco_swimmer.blank?

      @link_to_action ||= if @link_extra_params.present?
                            @deco_swimmer.send(@action_link_method, @link_extra_params)
                          else
                            @deco_swimmer.send(@action_link_method)
                          end
    end

    # Returns the proper tooltip key according to the specified @action_link_method;
    # Defaults to the tooltip for /swimmers/show/:id.
    def tooltip_key
      return 'meetings.tooltip.link.swimmer_results' if @action_link_method == :link_to_results

      'swimmers.go_to_dashboard'
    end
  end
end
