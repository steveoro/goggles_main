# frozen_string_literal: true

# = ToolsController
#
# Miscellaneous calculators and more
#
class ToolsController < ApplicationController
  before_action :authenticate_user!

  # Data entry for FIN score or target time computation.
  #
  def fin_score
    @gender_types = GogglesDb::GenderType.first(2)
    @event_types = GogglesDb::EventType.all_eventable
    @pool_types = GogglesDb::PoolType.all
    # Get just the last FIN Season for which we have standard timings:
    @last_fin_season = GogglesDb::StandardTiming.includes(:season_type)
                                                .joins(:season_type)
                                                .where('seasons.season_type_id': GogglesDb::SeasonType::MAS_FIN_ID)
                                                .last.season
    @category_types = @last_fin_season.category_types
  end

  # GET [XHR] - Compute FIN score or timing
  #
  # == Required params:
  # - season_id
  # - pool_type_id
  # - event_type_id
  # - gender_type_id
  # - category_type_id
  # - minutes, seconds, hundredths || score
  #
  # Uses <tt>commit</tt> value to discriminate between "compute score" or "compute time"
  #
  # == Renders:
  # Yields the API results as the JSON <tt>@result</tt> rendered by 'app/views/tools/compute_fin_score.js.erb'
  #
  # Basic structure:
  # <code>
  #   @result = {
  #     'score': computed_fin_score,
  #     'timing' : {
  #       'minutes': result_mins,
  #       'seconds': result_secs,
  #       'hundredths': result_hds
  #     }
  #   }
  # </code>
  #
  # For more details see Goggles API documentation, <tt>/tools/compute_fin_score</tt>
  #
  def compute_fin_score
    unless request.xhr?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    req_params = choose_which_api_req_params(fin_score_params['commit'])
    res = execute_request(req_params)
    unless res&.code == 200
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    store_params_in_cookies
    @result = JSON.parse(res.body)
    @standard_timing_label = @result['standard_timing_label']
  end
  #-- -------------------------------------------------------------------------
  #++

  # Data entry for Delta timing computation in between laps.
  # (Manual-only, no DB storage)
  #
  def delta_timings
    # (no-ops)
  end

  # GET [XHR] - Compute deltas for each timing present on the form grid.
  #
  def compute_deltas # rubocop:disable Metrics/AbcSize
    unless request.xhr?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @deltas = []
    prev_timing = Timing.new

    16.times do |index|
      next unless delta_t_params['m'].respond_to?(:fetch) &&
                  delta_t_params['s'].respond_to?(:fetch) &&
                  delta_t_params['h'].respond_to?(:fetch)

      curr_timing = Timing.new(
        minutes: delta_t_params['m'].fetch(index.to_s, 0),
        seconds: delta_t_params['s'].fetch(index.to_s, 0),
        hundredths: delta_t_params['h'].fetch(index.to_s, 0)
      )
      next if curr_timing.zero? || curr_timing < prev_timing

      @deltas << (curr_timing - prev_timing)
      prev_timing = curr_timing
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Strong parameter checking for GET /fin_score
  def fin_score_params
    params.permit(%w[
                    season_id season
                    pool_type_id pool_type_label
                    event_type_id event_type_label
                    gender_type_id category_type_id category_type_label
                    minutes seconds hundredths score
                    authenticity_token commit
                  ])
  end

  # Strong parameter checking for GET /compute_deltas
  def delta_t_params
    params.permit(m: {}, s: {}, h: {})
  end

  # Returns the parameter Hash for making the API request for
  # either the "compute FIN score" or "compute FIN timing" operation, depending on
  # <tt>commit_value</tt> (which is the localized submit button label).
  def choose_which_api_req_params(commit_value)
    if commit_value == I18n.t('tools.fin_score.target_timing.button_label')
      @target_type = 1 # Compute target time
      prepare_api_fin_time_params
    else
      @target_type = 2 # Compute target score
      prepare_api_fin_score_params
    end
  end

  # Returns the API request Hash for FIN score calculation
  def prepare_api_fin_score_params
    {
      minutes: fin_score_params['minutes'].to_i,
      seconds: fin_score_params['seconds'].to_i,
      hundredths: fin_score_params['hundredths'].to_i,
      season_id: fin_score_params['season_id'].to_i,
      gender_type_id: fin_score_params['gender_type_id'].to_i,
      pool_type_id: fin_score_params['pool_type_id'].to_i,
      event_type_id: fin_score_params['event_type_id'].to_i,
      category_type_id: fin_score_params['category_type_id'].to_i
    }
  end

  # Returns the API request Hash for FIN target time calculation
  def prepare_api_fin_time_params
    {
      score: fin_score_params['score'].to_i,
      season_id: fin_score_params['season_id'].to_i,
      gender_type_id: fin_score_params['gender_type_id'].to_i,
      pool_type_id: fin_score_params['pool_type_id'].to_i,
      event_type_id: fin_score_params['event_type_id'].to_i,
      category_type_id: fin_score_params['category_type_id'].to_i
    }
  end

  # Performs the API request using the specified <tt>req_params</tt>.
  # Returns a RestClient::Request::Response object, or nil in case of errors.
  def execute_request(req_params)
    jwt = GogglesDb::JWTManager.encode(
      { user_id: current_user.id },
      Rails.application.credentials.api_static_key
      # use defalt session length (@see GogglesDb::JWTManager::TOKEN_LIFE)
    )
    base_api_url = GogglesDb::AppParameter.config.settings(:framework_urls).api

    RestClient::Request.execute(
      method: :get,
      url: "#{base_api_url}/api/v3/tools/compute_score",
      headers: { 'Authorization' => "Bearer #{jwt}", params: req_params }
    )
  rescue StandardError
    nil
  end

  # Saves the current parameters choices into cookies for later reuse
  def store_params_in_cookies
    cookies[:event_type_id] = fin_score_params['event_type_id']
    cookies[:pool_type_id] = fin_score_params['pool_type_id']
    cookies[:gender_type_id] = fin_score_params['gender_type_id']
    cookies[:category_type_id] = fin_score_params['category_type_id']
  end
end
