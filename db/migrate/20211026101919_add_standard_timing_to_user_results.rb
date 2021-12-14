# frozen_string_literal: true

class AddStandardTimingToUserResults < ActiveRecord::Migration[6.0]
  def change
    add_reference(:user_results, :standard_timing)
  end
end
