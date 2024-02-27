# frozen_string_literal: true

class CreateRelayLaps < ActiveRecord::Migration[6.0]
  def change
    create_table :relay_laps do |t|
      t.string :relay_laps
      t.integer :minutes, limit: 3
      t.integer :seconds, limit: 2
      t.integer :hundredths, limit: 2
      t.integer :minutes_from_start, limit: 3
      t.integer :seconds_from_start, limit: 2
      t.integer :hundredths_from_start, limit: 2
      t.decimal :reaction_time, precision: 5, scale: 2
      t.integer :length_in_meters
      t.integer :position, limit: 3
      t.integer :stroke_cycles
      t.integer :breath_cycles

      t.references(:swimmer, null: false, foreign_key: true, type: :integer)
      t.references(:team, null: false, foreign_key: true, type: :integer)
      t.references(:meeting_relay_result, null: false, foreign_key: true, type: :integer)
      t.references(:meeting_relay_swimmer, null: false, foreign_key: true, type: :integer)

      t.timestamps
    end
  end
end
