# frozen_string_literal: true

class UpdateAPISettings < ActiveRecord::Migration[6.0]
  def change
    # --- Update DB settings to latest release setup:
    cfg = GogglesDb::AppParameter.versioning_row
    cfg.settings(:framework_urls).main = nil # (not used anymore)

    # Use the actual deployed staging API for anything else:
    # (Except for tests, where the actual endpoints will be mocked)
    cfg.settings(:framework_urls).api = "https://master-goggles.org:#{Rails.env.production? ? 445 : 446}"
    cfg.save!

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end
end
