# frozen_string_literal: true

class RenameLegacyDataImportAliases < ActiveRecord::Migration[6.0]
  def self.change
    rename_table(:data_import_swimmer_aliases, :swimmer_aliases)
    rename_table(:data_import_team_aliases, :team_aliases)
  end
end
