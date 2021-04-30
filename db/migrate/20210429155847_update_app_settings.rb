# frozen_string_literal: true

require 'version'

class UpdateAppSettings < ActiveRecord::Migration[6.0]
  def self.up
    app_settings_row = GogglesDb::AppParameter.versioning_row
    base_port = Rails.env.staging? ? 9080 : 8080
    app_settings_row.settings(:framework_urls).main = "0.0.0.0:#{base_port}"
    app_settings_row.settings(:framework_urls).api = "0.0.0.0:#{base_port + 1}"
    app_settings_row.settings(:framework_urls).admin = nil # (not used anymore)
    app_settings_row.settings(:framework_urls).chrono = nil # (not used anymore)

    # Override default E-mails:
    # app_settings_row.settings(:framework_emails).contact = '' # (company)
    # app_settings_row.settings(:framework_emails).admin = '' # (person)
    # app_settings_row.settings(:framework_emails).admin2 = '' # (person)
    # app_settings_row.settings(:framework_emails).devops = '' # (person)

    # Override default social URLs:
    # app_settings_row.settings(:social_urls).facebook = ''
    # app_settings_row.settings(:social_urls).linkedin = ''
    # app_settings_row.settings(:social_urls).twitter = ''
    app_settings_row.save!

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => '1.88.1'
    )
  end

  def self.down
    # Can't go back to old structure after this:
    raise ActiveRecord::IrreversibleMigration
  end
end
