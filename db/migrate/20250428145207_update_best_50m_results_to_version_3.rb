# frozen_string_literal: true

class UpdateBest50mResultsToVersion3 < ActiveRecord::Migration[6.1]
  def up
    update_view :best_50m_results, version: 3, revert_to_version: 2
  end

  def down
    # Explicitly drop V3 if it exists, then create V2.
    execute 'DROP VIEW IF EXISTS best_50m_results;'
    # Recreate the previous version (V2)
    create_view :best_50m_results, version: 2
  end
end
