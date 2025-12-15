# frozen_string_literal: true

# Adds from_start timing columns to data_import temporary tables
# to mirror the production table structure (laps, meeting_relay_swimmers, relay_laps)
class AddFromStartTimingToDataImportTables < ActiveRecord::Migration[6.1]
  def change
    # data_import_laps: add from_start timing columns
    change_table :data_import_laps do |t|
      t.integer :minutes_from_start, limit: 3, default: 0, comment: 'Minutes from race start'
      t.integer :seconds_from_start, limit: 2, default: 0, comment: 'Seconds from race start'
      t.integer :hundredths_from_start, limit: 2, default: 0, comment: 'Hundredths from race start'
    end

    # data_import_meeting_relay_swimmers: add from_start timing columns
    change_table :data_import_meeting_relay_swimmers do |t|
      t.integer :minutes_from_start, limit: 3, default: 0, comment: 'Minutes from race start'
      t.integer :seconds_from_start, limit: 2, default: 0, comment: 'Seconds from race start'
      t.integer :hundredths_from_start, limit: 2, default: 0, comment: 'Hundredths from race start'
    end

    # data_import_relay_laps: add from_start timing columns
    change_table :data_import_relay_laps do |t|
      t.integer :minutes_from_start, limit: 3, default: 0, comment: 'Minutes from race start'
      t.integer :seconds_from_start, limit: 2, default: 0, comment: 'Seconds from race start'
      t.integer :hundredths_from_start, limit: 2, default: 0, comment: 'Hundredths from race start'
    end
  end
end
