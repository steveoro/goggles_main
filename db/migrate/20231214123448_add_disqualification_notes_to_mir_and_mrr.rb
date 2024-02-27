# frozen_string_literal: true

class AddDisqualificationNotesToMIRAndMRR < ActiveRecord::Migration[6.0]
  def change
    add_column :meeting_individual_results, :disqualification_notes, :string, null: true
    add_column :meeting_relay_results, :disqualification_notes, :string, null: true
  end
end
