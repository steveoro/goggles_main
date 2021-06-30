# frozen_string_literal: true

require 'goggles_db/version'

class DataFixBadgesWithNullEntryTimeType < ActiveRecord::Migration[6.0]
  def self.up
    puts "\r\n--> Badges: setting missing default values for entry_time_type_id (1=personal)..."
    GogglesDb::Badge.where('entry_time_type_id is null').update_all(entry_time_type_id: 1)
    puts "Final count: #{GogglesDb::Badge.where('entry_time_type_id is null').count}"
  end

  def self.down
    # (no-op)
  end
end
