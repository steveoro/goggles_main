# frozen_string_literal: true

class UpdateBest50And100ResultsToVersion3 < ActiveRecord::Migration[6.1]
  def up
    update_view :best_50_and_100_results, version: 3, revert_to_version: 2
  end

  def down
    # Instead of relying on revert_to_version implicitly dropping V2,
    # explicitly drop V2 if it exists, then create V1.
    execute 'DROP VIEW IF EXISTS best_50_and_100_results;'
    # Recreate the previous version (V2)
    create_view :best_50_and_100_results, version: 2
  end
end
