# frozen_string_literal: true

# = IqProcessorJob
#
#   - author......: Steve A.
#   - last updated: 20210610
#
#  Calls the ImportQueue solver service.
#
class IqProcessorJob < ApplicationJob
  queue_as :iq

  # Performs the Job by executing a dedicated service object on each
  # involved row; cleans up all the rows marked as "done" at first.
  #
  # @see IqSolverService
  #
  def perform(*_args)
    GogglesDb::ImportQueue.where(done: true).delete_all
    GogglesDb::ImportQueue.all.each do |iq_row|
      IqSolverService.new.call(iq_row)
    end
  end
end
