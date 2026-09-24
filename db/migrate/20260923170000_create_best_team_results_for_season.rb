# frozen_string_literal: true

class CreateBestTeamResultsForSeason < ActiveRecord::Migration[6.1]
  def up
    create_view :best_team_results_for_season, version: 1
  end

  def down
    execute 'DROP VIEW IF EXISTS best_team_results_for_season;'
  end
end
