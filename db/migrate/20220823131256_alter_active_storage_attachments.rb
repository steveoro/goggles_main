# frozen_string_literal: true

require 'goggles_db/version'

class AlterActiveStorageAttachments < ActiveRecord::Migration[6.0]
  def self.up
    # NOTE: using default utf8mb4 will yield errors during build pipeline, complaining about the
    # DB rebuild from dump having a too long key (based on 4x 255 bytes in attachment #name)
    execute <<-SQL.squish
      ALTER TABLE active_storage_attachments CONVERT TO CHARACTER SET 'utf8';
    SQL

    execute <<-SQL.squish
      ALTER TABLE active_storage_blobs CONVERT TO CHARACTER SET 'utf8';
    SQL

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    # (no-op)
  end
end
