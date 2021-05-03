# frozen_string_literal: true

#
# = Icon components module
#
#   - version:  7.02.10
#   - author:   Steve A.
#
module Icon
  #
  # = Icon::CheckMarkComponent
  #
  # Renders either a check mark or an empty square depending on the
  # boolean +value+
  #
  class CheckMarkComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - value: a Boolean +true+/+false+ for the check mark (default: +false+)
    def initialize(value:)
      super
      @value = value
    end

    # Inline rendering
    def call
      content_tag(:i, '', class: @value ? 'fa fa-check-square-o' : 'fa fa-square-o')
    end
  end
end
