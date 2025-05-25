# frozen_string_literal: true

class CreateBestSwimmerAllTimeResults < ActiveRecord::Migration[6.1]
  def up
    create_view :best_swimmer_all_time_results, version: 1
  end

  def down
    # Use raw SQL for robust dropping and existence checking
    execute 'DROP VIEW IF EXISTS best_swimmer_all_time_results;'
  end
end
