# frozen_string_literal: true

class CreateBest50mResults < ActiveRecord::Migration[6.1]
  def up
    create_view :best_50m_results, version: 1
  end

  def down
    # Use raw SQL for robust dropping
    execute 'DROP VIEW IF EXISTS best_50m_results;'
    # drop_view :best_50m_results # Avoid this Scenic helper in 'down' if you want max robustness
  end
end
