# frozen_string_literal: true

class CreateBestSwimmer3yResults < ActiveRecord::Migration[6.1]
  def up
    create_view :best_swimmer3y_results, version: 1
  end

  def down
    # Use raw SQL for robust dropping and existence checking
    execute 'DROP VIEW IF EXISTS best_swimmer3y_results;'
  end
end
