# frozen_string_literal: true

#
# = Title components module
#
#   - version:  7-0.4.21
#   - author:   Steve A.
#
module Title
  #
  # = Title::BreadCrumbLinkComponent
  #
  # Title with CSS icon with a clickable parent title link for
  # browsing back to the specified parent page.
  #
  class BreadCrumbLinkComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>:title</tt> Main title text
    # - <tt>:css_icon</tt> Fontawesome CSS icon name, associated to the current <tt>:title</tt>
    # - <tt>:title_link</tt> URL for the title text link, if needed; defaults to +nil+
    # - <tt>:parent_title</tt> Parent title text
    # - <tt>:parent_link</tt> Parent URL for the parent text
    #
    def initialize(title:, css_icon:, parent_title:, parent_link:, title_link: nil)
      super
      @title = title
      @title_link = title_link
      @css_icon = css_icon
      @parent_title = parent_title
      @parent_link = parent_link
    end
  end
end
