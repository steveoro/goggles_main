# frozen_string_literal: true

class UpdateDefaultSettingsValues < ActiveRecord::Migration[6.0]
  def change
    app_base_row = GogglesDb::AppParameter.versioning_row
    # Chrono app is integrated in Main:
    app_base_row.settings(:framework_urls).chrono = nil
    # Email.it is not free anymore:
    app_base_row.settings(:framework_emails).contact = 'fasar.software@gmail.com'
    app_base_row.save!
  end
end
