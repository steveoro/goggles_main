# frozen_string_literal: true

class CreateGogglesCup3yBaseTimings < ActiveRecord::Migration[6.1]
  def up
    create_view :goggles_cup_3y_base_timings, version: 1
  end

  def down
    # Use raw SQL for robust dropping and existence checking
    execute 'DROP VIEW IF EXISTS goggles_cup_3y_base_timings;'
  end
end
