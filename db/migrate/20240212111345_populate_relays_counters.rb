# frozen_string_literal: true

class PopulateRelaysCounters < ActiveRecord::Migration[6.0]
  def self.up
    puts("\r\n--> Relay counters refresh...") # rubocop:disable Rails/Output
    Rake::Task['normalize:relay_counters'].invoke
  end

  def self.down
    # (no-op)
  end
end
