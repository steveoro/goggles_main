# frozen_string_literal: true

class UpdateGogglesCup3yBaseTimingsToVersion2 < ActiveRecord::Migration[6.1]
  def up
    update_view :goggles_cup_3y_base_timings, version: 2, revert_to_version: 1
  end

  def down
    execute 'DROP VIEW IF EXISTS goggles_cup_3y_base_timings;'
    create_view :goggles_cup_3y_base_timings, version: 1
  end
end
