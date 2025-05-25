# frozen_string_literal: true

class CreateBest50And100Results < ActiveRecord::Migration[6.1]
  def up
    create_view :best_50_and_100_results, version: 1
  end

  def down
    # Use raw SQL for robust dropping and existence checking
    execute 'DROP VIEW IF EXISTS best_50_and_100_results;'
  end
end
