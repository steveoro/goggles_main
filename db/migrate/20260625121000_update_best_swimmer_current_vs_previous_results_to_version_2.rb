# frozen_string_literal: true

class UpdateBestSwimmerCurrentVsPreviousResultsToVersion2 < ActiveRecord::Migration[6.1]
  def up
    update_view :best_swimmer_current_vs_previous_results, version: 2, revert_to_version: 1
  end

  def down
    execute 'DROP VIEW IF EXISTS best_swimmer_current_vs_previous_results;'
    create_view :best_swimmer_current_vs_previous_results, version: 1
  end
end
