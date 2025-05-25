# frozen_string_literal: true

class CreateBest50And100Results5yView < ActiveRecord::Migration[6.1]
  def up
    create_view :best_50_and_100_results5y, version: 1
  end

  def down
    # Use raw SQL for robust dropping and existence checking
    execute 'DROP VIEW IF EXISTS best_50_and_100_results5y;'
  end
end
