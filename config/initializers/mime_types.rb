# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# CSV & XLSX export MIME types:
Mime::Type.register 'text/csv', :csv unless Mime::Type.lookup_by_extension(:csv)
Mime::Type.register 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :xlsx unless Mime::Type.lookup_by_extension(:xlsx)
