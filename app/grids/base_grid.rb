# frozen_string_literal: true

# = BaseGrid
#
# Common DataGrid base.
#
class BaseGrid
  include Datagrid

  self.default_column_options = {
    # Uncomment to disable the default order
    # order: false,
    # Uncomment to make all columns HTML by default
    # html: true,
  }

  # Enable forbidden attributes protection
  self.forbidden_attributes_protection = true
  #-- -------------------------------------------------------------------------
  #++

  # Boolean column formatter helper
  #
  # == Params:
  # - <tt>name</tt>: column name
  # - <tt>args</tt>: options hash (blocks are supported)
  #
  def self.boolean_column(name, *args)
    column(name, *args) do |model|
      format(block_given? ? yield : model.send(name)) do |value|
        value ? '✔' : '-'
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
