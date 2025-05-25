# frozen_string_literal: true

class UpdateBest50mResultsToVersion4 < ActiveRecord::Migration[6.1]
  def up
    update_view :best_50m_results, version: 4, revert_to_version: 3
  end

  def down
    # Explicitly drop V4 if it exists, then create V3.
    execute 'DROP VIEW IF EXISTS best_50m_results;'
    # Recreate the previous version (V3)
    create_view :best_50m_results, version: 3
  end
end
