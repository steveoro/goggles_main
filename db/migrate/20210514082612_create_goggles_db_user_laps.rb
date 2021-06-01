# frozen_string_literal: true

class CreateGogglesDbUserLaps < ActiveRecord::Migration[6.0]
  def change
    drop_table :user_laps, if_exists: true

    create_table :user_laps do |t|
      t.references(:user_result, null: false, foreign_key: true, type: :integer)
      t.references(:swimmer, null: false, foreign_key: true, type: :integer)

      t.decimal :reaction_time, precision: 5, scale: 2
      t.integer :minutes, limit: 3
      t.integer :seconds, limit: 2
      t.integer :hundredths, limit: 2

      t.integer :length_in_meters
      t.integer :position, limit: 3

      t.integer :minutes_from_start, limit: 3
      t.integer :seconds_from_start, limit: 2
      t.integer :hundredths_from_start, limit: 2

      t.timestamps
    end
  end
end
