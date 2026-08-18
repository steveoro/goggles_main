# frozen_string_literal: true

class CreateMeetingRelayResultRows < ActiveRecord::Migration[6.1]
  def up
    create_view :meeting_relay_result_rows, version: 1
  end

  def down
    execute 'DROP VIEW IF EXISTS meeting_relay_result_rows;'
  end
end
