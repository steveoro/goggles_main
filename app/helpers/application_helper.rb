# frozen_string_literal: true

# = ApplicationHelper
#
# Common parent helper
module ApplicationHelper
  # Returns a static html checkbox icon for a given boolean value
  # == Params
  # - bool_value: true or false|nil to change the icon
  def check_mark_icon_for(bool_value)
    content_tag(:i, '', class: bool_value ? 'fa fa-check-square-o' : 'fa fa-square-o')
  end
end
