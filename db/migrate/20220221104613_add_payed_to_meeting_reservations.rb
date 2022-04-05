# frozen_string_literal: true

class AddPayedToMeetingReservations < ActiveRecord::Migration[6.0]
  def self.up
    change_table :meeting_reservations do |t|
      t.boolean :payed, null: false, default: false, index: true, bulk: true
    end
  end

  def self.down
    change_table :meeting_reservations do |t|
      t.remove :payed
    end
  end
end
