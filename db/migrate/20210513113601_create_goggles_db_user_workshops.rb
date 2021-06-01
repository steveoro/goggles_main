# frozen_string_literal: true

class CreateGogglesDbUserWorkshops < ActiveRecord::Migration[6.0]
  def self.up
    drop_table :user_workshops, if_exists: true

    create_table :user_workshops do |t|
      t.integer :lock_version, default: 0

      t.date :header_date
      t.string :header_year, limit: 10
      t.string :code, limit: 80
      t.string :description, limit: 100
      t.integer :edition
      t.text :notes

      # Add a "creator" (not necessarily the actual "performer"):
      t.references(:user, null: false, foreign_key: true, type: :integer)

      # "Creator" must select a team & all the fields below before adding a workshop:
      t.references(:team, null: false, foreign_key: true, type: :integer)
      t.references(:season, null: false, foreign_key: true, type: :integer)

      t.references(:edition_type, null: false, foreign_key: true, default: 3, type: :integer) # ('none')
      t.references(:timing_type, null: false, foreign_key: true, default: 1, type: :integer) # ('manual' registration)

      # This reference is not compulsory:
      t.references(:swimming_pool, null: true, type: :integer)

      t.boolean :autofilled
      t.boolean :off_season
      t.boolean :confirmed
      t.boolean :cancelled
      t.boolean :pb_acquired
      t.boolean :read_only

      t.timestamps
    end

    add_index :user_workshops, :header_date
    add_index :user_workshops, :header_year
    add_index :user_workshops, :code
  end

  def self.down
    drop_table :user_workshops
  end
end
