# frozen_string_literal: true

# = ChronoController
#
# Creates and manages new microtransactions for registering
# user-supplied lap timings.
#
class ChronoController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_rec_params, only: :rec
  before_action :validate_commit_params, only: :commit
  before_action :validate_delete_params, only: :delete

  # [GET] Lists the queue of pending lap registrations by the current_user
  def index
    # Retrieve only the master request, ignore the siblings (with UID: 'chrono-SEQ-IDX')
    @queues = GogglesDb::ImportQueue.for_user(current_user).for_uid('chrono')
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form entry for preparing a new lap-recording micro-transaction
  def new
    # Prepare pool_types, event_types & latest category_types belonging to the
    # last available FIN season for current_user:
    @last_chosen_swimmer = last_chosen_swimmer
    @last_chosen_swimming_pool = last_chosen_swimming_pool
    @last_chosen_team = last_chosen_team
    @last_chosen_city = last_chosen_city
    @seasons = GogglesDb::Season.includes(:season_type).in_range(Date.today - 1.year, Date.today + 3.months)
    @pool_types = GogglesDb::PoolType.all
    @event_types = GogglesDb::EventType.all_eventable
    @category_types = GogglesDb::Season.for_season_type(GogglesDb::SeasonType.mas_fin)
                                       .by_begin_date.last
                                       .category_types
  end
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Form entry for preparing a new lap-recording micro-transaction
  def rec
    # DEBUG
    logger.debug("\r\n\r\n#{params.inspect}\r\n")
    @adapter = IqRequest::ChronoRecParamAdapter.new(current_user, rec_params)
    store_rec_params_in_cookies
    @request_header = @adapter.to_request_hash.to_json
  end
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Store a new lap-recording micro-transaction
  #
  # == Params:
  # - header: JSON-ified common header parameters shared among all the detail requests
  # - payload: JSON array of detail data that will be converted to a list of new micro-transaction requests
  def commit
    # DEBUG
    logger.debug("\r\n\r\n#{params.inspect}\r\n")
    laps_list = parse_json_payload(commit_params[:payload])

    if laps_list.present?
      commit_import_queues(laps_list)
      flash[:notice] = t('chrono.messages.post_done')
    else
      # POST shouldn't happen on an empty payload:
      flash[:error] = t('chrono.messages.post_error')
    end

    redirect_to(chrono_index_path)
  end
  #-- -------------------------------------------------------------------------
  #++

  # [DELETE] Removes a group of ImportQueue rows
  #
  # == Params:
  # - id: the master row to be erased
  def delete
    # DEBUG
    logger.debug("\r\n\r\n#{delete_params.inspect}\r\n")
    queue = GogglesDb::ImportQueue.find_by_id(delete_params['id'])

    if queue.present?
      queue.sibling_rows
           .or(GogglesDb::ImportQueue.where(id: queue.id))
           .delete_all
      flash[:notice] = t('chrono.messages.delete_done')
    else
      flash[:error] = t('chrono.messages.delete_error')
    end

    redirect_to(chrono_index_path)
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Strong parameter checking for POST /rec
  def rec_params
    params.permit(IqRequest::ChronoRecParamAdapter::SUPPORTED_PARAMS + %w[authenticity_token commit])
  end

  # Strong parameter checking for POST /commit
  def commit_params
    params.permit(%w[header payload authenticity_token commit])
  end

  # Parameter checking for DELETE /delete (only :id shall be used)
  def delete_params
    params.permit(%w[id authenticity_token commit])
  end

  # Minimalistic /rec parameter validator. Checks that the user selected or typed-in new names
  # for a Meeting or a Workshop. Redirects to /new otherwise.
  def validate_rec_params
    return if rec_params['rec_type'].present? &&
              (rec_params['meeting_label'].present? || rec_params['user_workshop_label'].present?)

    flash[:error] = I18n.t('chrono.messages.error.missing_meeting_or_workshop_name')
    redirect_to(chrono_new_path)
  end

  # Validates presence of required /commit parameters. Redirects to /new otherwise.
  def validate_commit_params
    return if commit_params['header'].present? && commit_params['payload'].present?

    flash[:error] = I18n.t('chrono.messages.error.commit_missing_parameters')
    redirect_to(chrono_new_path)
  end

  # Validator for /delete; redirects to /index if the row doesn't exist and doesn't belong to this user.
  def validate_delete_params
    return if delete_params['id'].present? &&
              GogglesDb::ImportQueue.for_user(current_user).where(id: delete_params['id']).exists?

    flash[:error] = I18n.t('chrono.messages.error.delete_invalid_parameters')
    redirect_to(chrono_index_path)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Safe-JSON parser. Returns +nil+ on parse error.
  def parse_json_payload(json_text)
    ActiveSupport::JSON.decode(json_text || '')
  rescue ActiveSupport::JSON.parse_error
    nil
  end

  # Saves the current choices for /rec into cookies
  # rubocop:disable Metrics/AbcSize
  def store_rec_params_in_cookies
    cookies[:season_id] = rec_params[:season_id]
    cookies[:meeting_id] = rec_params[:meeting_id]
    cookies[:meeting_label] = rec_params[:meeting_label]
    cookies[:user_workshop_id] = rec_params[:user_workshop_id]
    cookies[:user_workshop_label] = rec_params[:user_workshop_label]

    cookies[:event_date] = rec_params[:event_date]
    cookies[:event_type_id] = rec_params[:event_type_id]

    cookies[:swimming_pool_id] = rec_params[:swimming_pool_id]
    cookies[:swimming_pool_label] = rec_params[:swimming_pool_label]
    cookies[:swimming_pool_name] = rec_params[:swimming_pool_name] || rec_params[:swimming_pool_label]
    cookies[:pool_type_id] = rec_params[:pool_type_id]

    cookies[:swimmer_id] = rec_params[:swimmer_id]
    cookies[:swimmer_label] = rec_params[:swimmer_label]
    cookies[:swimmer_complete_name] = rec_params[:swimmer_complete_name]
    cookies[:swimmer_year_of_birth] = rec_params[:swimmer_year_of_birth]
    cookies[:gender_type_id] = rec_params[:gender_type_id]

    cookies[:category_type_id] = rec_params[:category_type_id]
    cookies[:team_id] = rec_params[:team_id]
    cookies[:team_name] = rec_params[:team_name] || rec_params[:team_label]

    cookies[:city_id] = rec_params[:city_id]
    cookies[:city_label] = rec_params[:city_label]
    cookies[:city_name] = rec_params[:city_name] || rec_params[:city_label]
    cookies[:city_area] = rec_params[:city_area]
    cookies[:city_country_code] = rec_params[:city_country_code]
  end
  # rubocop:enable Metrics/AbcSize

  # Returns the last chosen Swimmer from the cookies or the default one besed on the current user.
  def last_chosen_swimmer
    return GogglesDb::Swimmer.find_by_id(cookies[:swimmer_id]) if cookies[:swimmer_id].to_i.positive?

    if cookies[:swimmer_complete_name].present?
      return GogglesDb::Swimmer.new(
        complete_name: cookies[:swimmer_complete_name],
        year_of_birth: cookies[:swimmer_year_of_birth],
        gender_type_id: cookies[:gender_type_id]
      )
    end

    current_user.swimmer
  end

  # Returns the last chosen SwimmingPool values restored from the cookies, or nil.
  def last_chosen_swimming_pool
    return nil unless cookies[:swimming_pool_id].to_i.positive? || cookies[:swimming_pool_name].present?

    GogglesDb::SwimmingPool.find_by_id(cookies[:swimming_pool_id]) ||
      GogglesDb::SwimmingPool.new(
        name: cookies[:swimming_pool_name],
        pool_type_id: cookies[:pool_type_id]
      )
  end

  # Returns the last chosen Team values restored from the cookies or nil.
  def last_chosen_team
    return nil unless cookies[:team_id].to_i.positive? || cookies[:team_name].present? || cookies[:team_label].present?

    GogglesDb::Team.find_by_id(cookies[:team_id]) ||
      GogglesDb::Team.new(
        name: cookies[:team_name] || cookies[:team_label],
        editable_name: cookies[:team_name]
      )
  end

  # Returns the last chosen City values restored from the cookies or nil.
  def last_chosen_city
    return nil unless cookies[:city_id].to_i.positive? || cookies[:city_name].present? || cookies[:city_label].present?

    GogglesDb::City.find_by_id(cookies[:city_id]) ||
      GogglesDb::City.new(
        name: cookies[:city_name] || cookies[:city_label],
        area: cookies[:city_area],
        country_code: cookies[:city_country_code]
      )
  end

  # Returns the last recored timing data, minus the order (which is not used in the actual result).
  def overall_result_timing(laps_list)
    return {} unless laps_list.present?
    return laps_list if laps_list.is_a?(Hash)

    laps_list.last.reject { |key| key == 'order' }
  end

  # Creates a new ImportQueue for each detail row data.
  # Fails fast on JSON parse error.
  # Uses the actual JSONified header string for building the shared request base.
  #
  # == Params:
  # - laps_list: the list of Hash data from the actual detail payload
  #
  def commit_import_queues(laps_list)
    adapter = IqRequest::ChronoRecParamAdapter.from_request_data(commit_params['header'])
    # Update parent result timing using last lap:
    adapter.update_result_data(overall_result_timing(laps_list))
    parent_id = nil
    laps_list = [laps_list] if laps_list.is_a?(Hash)

    # Create an IQ row for each lap data obtained from the payload, starting from last lap
    # which, allegedly, should contain the last overall timing:
    laps_list.reverse.each_with_index do |lap_data, index|
      # DEBUG
      logger.debug("\r\n- lap_data: #{lap_data.inspect}")

      # Merge detail request data with common header:
      adapter.update_rec_detail_data(lap_data)
      # DEBUG
      logger.debug("- full request:\r\n#{adapter.request_hash.inspect}")

      iq_row = GogglesDb::ImportQueue.create!(
        user: current_user,
        uid: index.zero? ? 'chrono' : "chrono-#{parent_id}",
        import_queue_id: parent_id,
        request_data: adapter.request_hash.to_json,
        solved_data: {}.to_json
      )
      # Set the parent ID for next processed rows only during first run:
      parent_id = iq_row.id if index.zero?
    end
  end
end
