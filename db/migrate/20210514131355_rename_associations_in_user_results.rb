# frozen_string_literal: true

class RenameAssociationsInUserResults < ActiveRecord::Migration[6.0]
  def change
    rename_column :user_results, :user_workshops_id, :user_workshop_id
    rename_column :user_results, :swimming_pools_id, :swimming_pool_id
  end
end
