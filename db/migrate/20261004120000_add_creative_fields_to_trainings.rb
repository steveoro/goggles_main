# frozen_string_literal: true

class AddCreativeFieldsToTrainings < ActiveRecord::Migration[6.1]
  def change
    # Actual training session date, set by the operator (independent from created_at):
    add_column :trainings, :training_date, :datetime, null: true, default: nil, after: :title
    add_index :trainings, :training_date

    # "Who ran the training" (free text) & "who uploaded/created the picture" (free text):
    add_column :trainings, :training_by, :string, limit: 100, null: true, default: nil, after: :training_date
    add_column :trainings, :created_by, :string, limit: 100, null: true, default: nil, after: :training_by

    # Optional link to the Swimmer page for the "created by" label:
    add_reference :trainings, :swimmer, foreign_key: true, type: :integer, null: true, default: nil
  end
end
