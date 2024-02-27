# frozen_string_literal: true

# rubocop:disable Rails/Output
class DataFixNormalizeMrsNewColumns < ActiveRecord::Migration[6.0]
  def self.up
    puts("\r\n--> MRS nil fix/normalization...")
    Rake::Task['app:normalize:relay_laps'].invoke
  end

  def self.down
    # (no-op)
  end
end
# rubocop:enable Rails/Output
