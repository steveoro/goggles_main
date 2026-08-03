# frozen_string_literal: true

class AddMaxAnonymousReqSetting < ActiveRecord::Migration[6.1]
  def up
    app_base_row = GogglesDb::AppParameter.versioning_row
    app_base_row.settings(:app).max_anonymous_req = 500
    app_base_row.save!
  end

  def down
    app_base_row = GogglesDb::AppParameter.versioning_row
    app_base_row.settings(:app).max_anonymous_req = nil
    app_base_row.save!
  end
end
