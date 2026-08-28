# frozen_string_literal: true

class UpdateMeetingRelayResultRowsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :meeting_relay_result_rows, version: 2, revert_to_version: 1
  end
end
