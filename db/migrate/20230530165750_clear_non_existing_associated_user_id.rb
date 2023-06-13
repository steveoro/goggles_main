# frozen_string_literal: true

class ClearNonExistingAssociatedUserId < ActiveRecord::Migration[6.0]
  def change
    # As of this version, no user exists anymore having ID > 4; 'need to align swimmers too.
    GogglesDb::Swimmer.where('associated_user_id > 4').update_all(associated_user_id: nil)

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end
end
