# frozen_string_literal: true

class UpdateMeetingIndividualResultRowsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :meeting_individual_result_rows, version: 2, revert_to_version: 1
  end
end
