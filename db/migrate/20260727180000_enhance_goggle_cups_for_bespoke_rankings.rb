# frozen_string_literal: true

class EnhanceGoggleCupsForBespokeRankings < ActiveRecord::Migration[6.1]
  def up
    # 1. Add foreign key constraint on team_id → teams.id
    add_foreign_key :goggle_cups, :teams, name: 'fk_goggle_cups_teams'

    # 2. Unique index on [team_id, season_year, description]
    add_index :goggle_cups, %i[team_id season_year description],
              unique: true, name: 'idx_goggle_cups_team_year_desc'

    # 3. New column: comma-separated swimmer IDs
    add_column :goggle_cups, :swimmers_ids, :text, null: true, default: nil

    # 4. New column: JSON ranking data
    add_column :goggle_cups, :ranking_data, :json, null: true, default: nil
  end

  def down
    remove_column :goggle_cups, :ranking_data
    remove_column :goggle_cups, :swimmers_ids
    remove_index :goggle_cups, name: 'idx_goggle_cups_team_year_desc'
    remove_foreign_key :goggle_cups, name: 'fk_goggle_cups_teams'
  end
end
