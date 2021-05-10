# frozen_string_literal: true

# = ChronoController
#
# Creates and manages new microtransactions for registering
# user-supplied lap timings.
#
class ChronoController < ApplicationController
  # before_action :authenticate_user!

  # [GET] Lists the queue of pending lap registrations by the current_user
  def index
    # (no-op)
  end

  # [GET] Form entry for preparing a new lap-recording micro-transaction
  def new
    # (no-op)
  end

  # [POST] Store a new lap-recording micro-transaction
  def rec
    values = begin
      ActiveSupport::JSON.decode(params[:payload] || '')
    rescue ActiveSupport::JSON.parse_error
      nil
    end

    if values
      logger.debug("\r\n- Values: #{values.inspect}")
      # TODO
      # GogglesDb::ImportQueue.create!(
      #   user: current_user,
      #   request_data: {
      #     source: 'chrono',
      #     date: date,
      #     season: nil, # +type
      #     meeting: nil,
      #     event: nil, # +type
      #     category: nil, # +type
      #     pool: nil, # +type
      #     swimmer: nil, # +gender
      #     values: values # actual data
      #   }.to_json
      # )
      flash[:notice] = t('chrono.messages.post_done')
    else
      flash[:error] = t('chrono.messages.post_error')
    end

    redirect_to(chrono_index_path)
  end
end
