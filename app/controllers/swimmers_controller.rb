# frozen_string_literal: true

# = SwimmersController
#
class SwimmersController < ApplicationController
  before_action :authenticate_user!, only: %i[history_recap history]
  before_action :prepare_swimmer

  # GET /swimmers/:id
  # Show Swimmer details & main stats. AKA: Swimmer radiography.
  # Requires an existing Swimmer.
  #
  # == Params
  # - :id => a valid Swimmer ID, required
  def show
    if @swimmer.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @stats = GogglesDb::SwimmerStat.new(@swimmer)
  end
  #-- -------------------------------------------------------------------------
  #++

  # GET /swimmers/history_recap/:id
  # Search form for a specific event history & stats along the whole
  # Swimmer history.
  # Requires an existing Swimmer.
  #
  # == Params
  # - :id => a valid Swimmer ID, required
  def history_recap
    if @swimmer.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    # Prepare the list of selectable & available events for the current swimmer
    @event_type_list = GogglesDb::EventType.all_eventable.map do |event_type|
      count = GogglesDb::MeetingIndividualResult.includes(:event_type)
                                                .where(swimmer_id: @swimmer.id, 'event_types.id': event_type.id)
                                                .count
      next if count.zero?

      count25 = GogglesDb::MeetingIndividualResult.includes(:event_type, :pool_type)
                                                  .where(
                                                    swimmer_id: @swimmer.id,
                                                    'event_types.id': event_type.id,
                                                    'pool_types.id': GogglesDb::PoolType::MT_25_ID
                                                  ).count
      {
        id: event_type.id,
        label: event_type.long_label, # I18n
        count25: count25,
        count50: count - count25,
        count: count
      }
    end
    @event_type_list.compact!
    prepare_chart_recap_data
  end

  # GET /swimmers/history/:id
  # Filter & display specific event history + stats for a specific swimmer.
  # Requires an existing Swimmer and a valid EventType.
  #
  # == Required params:
  # - :id => a valid Swimmer ID
  # - :event_type_id => a valid EventType ID
  #
  def history
    if @swimmer.nil? || !GogglesDb::EventType.exists?(history_params[:event_type_id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @event_type = GogglesDb::EventType.find(history_params[:event_type_id])
    @grid = HistoryGrid.new(grid_filter_params) do |scope|
      scope.where(
        swimmer_id: @swimmer.id,
        event_types: { id: @event_type.id }
      )
    end
    prepare_chart_detail_data
  end
  #-- -------------------------------------------------------------------------
  #++

  protected

  # /show action strong parameters checking
  def swimmer_params
    params.permit(:id)
  end

  # /history actions strong parameters checking
  def history_params
    params.permit(:id, :event_type_id)
  end

  # Default whitelist for datagrid parameters
  # (NOTE: member variable is needed by the view)
  def grid_filter_params
    @grid_filter_params = params.fetch(:history_grid, {})
                                .permit(
                                  :id, :event_type_id,
                                  :pool_type, :meeting_date,
                                  :descending, :order
                                )
    # Set default ordering for the datagrid:
    @grid_filter_params.merge(order: :timing) unless @grid_filter_params.key?(:order)
    @grid_filter_params
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Setter for the @swimmer member variable either based on params or cookies.
  # Updates the cookies with the new value.
  def prepare_swimmer
    @swimmer = GogglesDb::Swimmer.find_by(id: swimmer_params[:id])
    @swimmer ||= GogglesDb::Swimmer.find_by(id: cookies[:swimmer_id]) if cookies[:swimmer_id].present?
    cookies[:swimmer_id] = @swimmer.id if @swimmer.present?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepares the swimmer history_recap chart data members, mapping each event type label
  # to its percentage of the total accounted events.
  #
  # == Returns:
  # Prepares the following members:
  # - @event_type_list: unfiltered list of available event types (1 Hash for each event)
  # - @event_total: overall total for all events accounted for
  # - @chart_data25: filtered list of events occurred in a 25m pool
  # - @chart_data50: filtered list of events occurred in a 50m pool
  #
  def prepare_chart_recap_data
    @event_type_list = @event_type_list.sort_by { |hsh| hsh[:count] }.reverse!
    @event_total = @event_type_list.sum { |e| e[:count] }
    prepare_chart_recap_data25(@event_type_list, @event_total)
    prepare_chart_recap_data50(@event_type_list, @event_total)
  end

  # Prepares the data Hash needed to render the swimmer history recap pie chart,
  # with data filtered for events occuring in a 25m pool only.
  #
  # == Params:
  # - data_hash: the overall event Hash list to be filtered
  # - event_total: total count of events to be used for percentage calculation
  #
  # == Returns:
  # Sets the @chart_data25 member array & the @event25_total count.
  def prepare_chart_recap_data25(data_hash, event_total)
    @chart_data25 = data_hash.map do |hsh|
      percent = (hsh[:count25] * 100 / event_total).round(2)
      {
        key: hsh[:label],
        value: [percent, 1.0].max,
        count: hsh[:count25],
        typeLabel: GogglesDb::PoolType.mt_25.label
      }
    end
    @event25_total = @chart_data25.sum { |e| e[:count] }
  end

  # Prepares the data Hash needed to render the swimmer history recap pie chart,
  # with data filtered for events occuring in a 50m pool only.
  #
  # == Params:
  # - data_hash: the overall event Hash list to be filtered
  # - event_total: total count of events to be used for percentage calculation
  #
  # == Returns:
  # Sets the @chart_data50 member array & the @event50_total count.
  def prepare_chart_recap_data50(data_hash, event_total)
    @chart_data50 = data_hash.map do |hsh|
      percent = (hsh[:count50] * 100 / event_total).round(2)
      {
        key: hsh[:label],
        value: [percent, 1.0].max,
        count: hsh[:count50],
        typeLabel: GogglesDb::PoolType.mt_50.label
      }
    end
    @event50_total = @chart_data50.sum { |e| e[:count] }
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepares the swimmer history (event detail) chart data members,
  # mapping each result date to the absolute timing data value.
  #
  # == Returns:
  # Sets both @chart_data25 and @chart_data50 members.
  def prepare_chart_detail_data
    data_hash = @grid.assets.map do |mir|
      {
        x: mir.meeting.header_date, y: mir.to_timing, pool_type_id: mir.pool_type.id
      }
    end
    prepare_chart_detail_data25(data_hash)
    prepare_chart_detail_data50(data_hash)
  end

  # Prepares the data Hash needed to render the swimmer history event detail chart,
  # with data filtered for events occuring in a 25m pool only.
  #
  # == Params:
  # - data_hash: the overall event Hash list to be filtered
  #
  # == Returns:
  # Sets the @chart_data25 member array.
  def prepare_chart_detail_data25(data_hash)
    @chart_data25 = data_hash.select { |hsh| hsh[:pool_type_id] == GogglesDb::PoolType::MT_25_ID }
                             .map do |hsh|
      {
        x: hsh[:x].strftime('%Y%m%d').to_i, xLabel: hsh[:x].to_s,
        y: hsh[:y].to_hundredths, yLabel: hsh[:y].to_s,
        poolTypeId: hsh[:pool_type_id]
      }
    end
    @chart_data25.sort_by! { |hsh| hsh[:x] }
  end

  # Prepares the data Hash needed to render the swimmer history event detail chart,
  # with data filtered for events occuring in a 50m pool only.
  #
  # == Params:
  # - data_hash: the overall event Hash list to be filtered
  #
  # == Returns:
  # Sets the @chart_data50 member array.
  def prepare_chart_detail_data50(data_hash)
    @chart_data50 = data_hash.select { |hsh| hsh[:pool_type_id] == GogglesDb::PoolType::MT_50_ID }
                             .map do |hsh|
      {
        x: hsh[:x].strftime('%Y%m%d').to_i, xLabel: hsh[:x].to_s,
        y: hsh[:y].to_hundredths, yLabel: hsh[:y].to_s,
        poolTypeId: hsh[:pool_type_id]
      }
    end
    @chart_data50.sort_by! { |hsh| hsh[:x] }
  end
end
