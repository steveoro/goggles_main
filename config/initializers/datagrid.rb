# frozen_string_literal: true

Datagrid.configure do |config|
  # Defines date formats that can be used to parse date.
  # Note that multiple formats can be specified but only first format used to format date as string.
  # Other formats are just used for parsing date from string in case your App uses multiple.
  config.date_formats = ['%Y-%m-%d', '%d/%m/%Y']

  # Defines timestamp formats that can be used to parse timestamp.
  # Note that multiple formats can be specified but only first format used to format timestamp as string.
  # Other formats are just used for parsing timestamp from string in case your App uses multiple.
  config.datetime_formats = ['%Y-%m-%d %h:%M:%s']
end
