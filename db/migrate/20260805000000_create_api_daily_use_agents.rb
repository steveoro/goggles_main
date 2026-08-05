# frozen_string_literal: true

class CreateAPIDailyUseAgents < ActiveRecord::Migration[6.1]
  def up
    create_table :api_daily_use_agents do |t|
      t.integer :lock_version, default: 0
      t.string :user_agent, null: false
      t.date :day, null: false
      t.bigint :count, default: 0

      t.timestamps
    end

    add_index :api_daily_use_agents, %i[day user_agent], unique: true

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def down
    drop_table :api_daily_use_agents
  end
end
