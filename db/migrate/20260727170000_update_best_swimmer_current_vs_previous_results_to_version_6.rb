# frozen_string_literal: true

class UpdateBestSwimmerCurrentVsPreviousResultsToVersion6 < ActiveRecord::Migration[6.1]
  def up
    update_view :best_swimmer_current_vs_previous_results, version: 6, revert_to_version: 5
  end

  def down
    execute 'DROP VIEW IF EXISTS best_swimmer_current_vs_previous_results;'
    create_view :best_swimmer_current_vs_previous_results, version: 5
  end
end
