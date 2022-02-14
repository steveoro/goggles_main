# frozen_string_literal: true

#
# = Grid components module
#
#   - version:  7.0.3.25
#   - author:   Steve A.
#
module Grid
  #
  # = Grid::FilterShowButtonComponent
  #
  # Renders a button the toggles the visibility of the filter form for the grid.
  #
  # The filter form is assumed to have the <tt>filter-panel</tt> DOM ID.
  # (@see app/views/datagrid/_form.html.haml)
  #
  class FilterShowButtonComponent < ViewComponent::Base; end
end
