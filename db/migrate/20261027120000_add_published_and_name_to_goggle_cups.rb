# frozen_string_literal: true

# Adds publish-state and short-name columns to goggle_cups:
#
# - +published+ marks the single cup "made visible" per (team_id, season_year)
#   affiliation; toggling it on for a cup resets the flag on its siblings.
# - +name+ is the recurring cup identity across seasons (e.g. "GoggleCup"),
#   while +description+ stays the per-edition variant; existing rows get
#   name = description.
# - +published_key+ is a stored generated column which is NULL for unpublished
#   cups; its unique index enforces the one-published-cup-per-affiliation rule
#   even under concurrent toggles (MariaDB unique keys ignore NULLs).
class AddPublishedAndNameToGoggleCups < ActiveRecord::Migration[6.1]
  def up
    add_column :goggle_cups, :published, :boolean, null: false, default: false
    add_column :goggle_cups, :name, :string, limit: 60

    execute('UPDATE goggle_cups SET name = description WHERE name IS NULL')
    change_column_null :goggle_cups, :name, false

    add_column :goggle_cups, :published_key, :virtual,
               as: "IF(published, CONCAT(team_id, '-', season_year), NULL)",
               type: :string, stored: true
    add_index :goggle_cups, :published_key, unique: true
    add_index :goggle_cups, %i[team_id season_year published]
  end

  def down
    remove_index :goggle_cups, column: %i[team_id season_year published]
    remove_index :goggle_cups, column: :published_key
    remove_column :goggle_cups, :published_key
    remove_column :goggle_cups, :name
    remove_column :goggle_cups, :published
  end
end
