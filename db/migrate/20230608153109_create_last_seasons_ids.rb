# frozen_string_literal: true

class CreateLastSeasonsIds < ActiveRecord::Migration[6.0]
  def change
    create_view :last_seasons_ids

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end
end
