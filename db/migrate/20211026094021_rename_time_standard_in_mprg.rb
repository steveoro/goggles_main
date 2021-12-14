# frozen_string_literal: true

class RenameTimeStandardInMprg < ActiveRecord::Migration[6.0]
  def change
    rename_column(:meeting_programs, :time_standard_id, :standard_timing_id)
  end
end
