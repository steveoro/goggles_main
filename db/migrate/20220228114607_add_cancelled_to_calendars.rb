# frozen_string_literal: true

class AddCancelledToCalendars < ActiveRecord::Migration[6.0]
  def change
    change_table :calendars, bulk: true do |t|
      t.boolean :cancelled, default: false, index: true
    end
  end
end
