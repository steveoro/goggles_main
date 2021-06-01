# frozen_string_literal: true

class ChangeUserResults < ActiveRecord::Migration[6.0]
  def change
    add_reference(:user_results, :user_workshops, null: false, foreign_key: true, type: :bigint)
    add_reference(:user_results, :swimming_pools, null: true, foreign_key: false)

    remove_index :user_results, name: :idx_user_results_user
    add_foreign_key(:user_results, :users)

    remove_index :user_results, name: :meeting_id_rank
    remove_column :user_results, :meeting_individual_result_id
  end
end
