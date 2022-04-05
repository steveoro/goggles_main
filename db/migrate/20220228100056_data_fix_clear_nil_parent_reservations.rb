# frozen_string_literal: true

class DataFixClearNilParentReservations < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.info("\r\n--> Clear reservations missing a parent link...")
    GogglesDb::MeetingEventReservation.where(meeting_reservation_id: nil).delete_all
    GogglesDb::MeetingRelayReservation.where(meeting_reservation_id: nil).delete_all
  end

  def self.down
    # (no-op)
  end
end
