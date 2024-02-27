# frozen_string_literal: true

class RemoveStringColumnFromRelayLaps < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :relay_laps, :relay_laps
  end

  def self.down
    # Can't go back to old structure after this:
    raise ActiveRecord::IrreversibleMigration
  end
end
