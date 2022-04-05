# frozen_string_literal: true

class DataFixClearInvalidParentReservations < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.info("\r\n--> Clear reservations with a non-existent parent link...")
    seek_and_destroy_unbound!(GogglesDb::MeetingEventReservation)
    seek_and_destroy_unbound!(GogglesDb::MeetingRelayReservation)
  end

  def self.down
    # (no-op)
  end

  def self.seek_and_destroy_unbound!(sibling_klass)
    all = sibling_klass.select(:meeting_reservation_id).distinct.pluck(:meeting_reservation_id).uniq
    not_found = all.delete_if { |id| GogglesDb::MeetingReservation.exists?(id) }
    return unless not_found.any?

    Rails.logger.info("    #{sibling_klass} without a parent link: #{not_found.size}; clearing...")
    to_be_cleared = sibling_klass.where(meeting_reservation_id: not_found)
    to_be_cleared.delete_all
  end
end
