# frozen_string_literal: true

# = RelayLapsController
#
# Lap timings management controller customized for RelayLap instances.
# Handles CRUD management for MeetingRelaySwimmers (as a sibling of MRR) &
# RelayLaps (as a sibling of MRS).
#
# rubocop:disable Metrics/ClassLength
class RelayLapsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_modal_request, only: %i[edit_modal create]
  before_action :validate_row_request, only: %i[update destroy]
  before_action :prepare_user_teams, :prepare_managed_teams, only: %i[create update destroy]

  # [XHR POST /relay_laps/edit_modal] renders the Laps edit modal for the specified result.
  #
  # == Constraints:
  # - 1 modal per page (shown / defined);
  # - same target DOM for rendering ('#lap-edit-modal-container', same for laps);
  # - overwrites previous contents of the target DOM.
  #
  def edit_modal
    # (Won't render anything if the relay result is not found)
  end
  #-- -------------------------------------------------------------------------
  #++

  # [XHR POST /relay_lap/create] creates a new, zeroed Lap model, appended as a new lap
  # form row to the HTML table.
  # Works for both associations MRR->MRS, MRS->RelayLap.
  #
  # == Params:
  # - <tt>result_id</tt>: parent result ID (either a MRR or a MRS)
  #
  # - <tt>result_class</tt>: parent result class name ('MeetingRelayResult' or 'MeetingRelaySwimmer')
  #
  # - <tt>length_in_meters</tt>: lap/sub-lap length in meters; for MRS, this coincides with their actual
  #   length in meters, which is the final target length of the relay phase being added.
  #   (Example: 4x200 => second phase added => target length = length_in_meters = 400)
  #   The new row will be actually created and added to the list only if there aren't already other
  #   relay swimmer results existing for the requested target <tt>length_in_meters</tt>.
  #   (Although the "add fraction" button should be already disabled in this case, this is an additional
  #    backend check to prevent any data corruption.)
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    @alert_msg = I18n.t('search_view.errors.invalid_request')
    @alert_class = 'alert-warning'
    valid_request = false
    event_type = @relay_result&.event_type
    check_and_set_lap_edit_and_report_mistake_flags # (Needs @relay_result to be set)

    # ** MRS creation **
    if @parent_result.is_a?(GogglesDb::MeetingRelayResult) && GogglesDb::Badge.exists?(modal_params[:badge_id])
      target_length = modal_params[:length_in_meters].to_i
      valid_request = target_length.positive? && @parent_result.meeting_relay_swimmers.map(&:length_in_meters).exclude?(target_length)
      render(:update) && return unless valid_request

      relay_order = target_length / event_type.phase_length_in_meters

    # ** RELAY_LAP creation **
    elsif @parent_result.is_a?(GogglesDb::MeetingRelaySwimmer) && event_type.phase_length_in_meters > 50 &&
          (@parent_result.relay_laps.count < (event_type.phase_length_in_meters / 50) - 1)
      # Compute remaining sub-lap lengths available to be allocated:
      allocated_lengths = @parent_result.relay_laps.map(&:length_in_meters)
      max_sublaps = (event_type.phase_length_in_meters / 50) - 1
      target_length = ((1..max_sublaps).map { |sublap_idx| @parent_result.length_in_meters - (sublap_idx * 50) } - allocated_lengths).first
      valid_request = target_length.positive? && @parent_result.relay_laps.map(&:length_in_meters).exclude?(target_length)
      render(:update) && return unless valid_request

      # Use same relay_order as containing MRS for siblings RelayLap: (e.g.: 150/200 + 1 = 1)
      relay_order = (target_length / event_type.phase_length_in_meters) + 1

      # ELSE: ** (Unsupported / invalid request) **
    end

    if valid_request && new_zeroed_lap(target_length, relay_order).save
      @alert_msg = I18n.t('laps.modal.msgs.create_successful')
      @alert_class = 'alert-success'
      # Store overall edits counter:
      GogglesDb::APIDailyUse.increase_for!("CREATE-RELAYLAP-#{current_user.id}")

    elsif valid_request
      @alert_msg = I18n.t('search_view.errors.submit_generic_failure')
      @alert_class = 'alert-danger'
    end
    render(:update)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # [XHR PUT /relay_lap/:id] updates an existing lap row given the parameters.
  # Except for the current row :id param, each lap row field is assumed to be indexed.
  #
  # == Required Params:
  # - <tt>id</tt>: existing row ID
  # - <tt>result_id[]</tt>: existing parent row ID (indexed)
  # - <tt>result_class[]</tt>: existing parent row class (indexed)
  #
  # == Example parameters:
  #   {
  #     "result_id"             => { "<ROW_INDEX>" => "<MIR_ID>" },
  #     "result_class"          => { "<ROW_INDEX>" => "GogglesDb::MeetingRelayResult" },
  #     "id"                    => "<LAP_ID>",
  #     "length_in_meters"      => { "<ROW_INDEX>" => "150" },
  #     "minutes_from_start"    => { "<ROW_INDEX>" =>"3" },
  #     "seconds_from_start"    => { "<ROW_INDEX>" => "55" },
  #     "hundredths_from_start" => { "<ROW_INDEX>" => "10" },
  #   }
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def update
    @alert_msg = I18n.t('search_view.errors.invalid_request')
    @alert_class = 'alert-warning'
    render && return unless @relay_result && @curr_lap

    check_and_set_lap_edit_and_report_mistake_flags # (Needs @relay_result to be set)

    # Update timing from start for current lap
    @curr_lap.length_in_meters = rows_params[:length_in_meters]&.values&.first || @curr_lap.length_in_meters
    @curr_lap.minutes_from_start = rows_params[:minutes_from_start]&.values&.first || @curr_lap.minutes_from_start
    @curr_lap.seconds_from_start = rows_params[:seconds_from_start]&.values&.first || @curr_lap.seconds_from_start
    @curr_lap.hundredths_from_start = rows_params[:hundredths_from_start]&.values&.first || @curr_lap.hundredths_from_start

    # Recompute current delta giving precedence to #timing_from_start:
    if recompute_delta_for!(@curr_lap) && recompute_following_laps_timings!(@curr_lap)
      @alert_msg = I18n.t('laps.modal.msgs.submit_successful')
      @alert_class = 'alert-success'
      # Store overall edits counter:
      GogglesDb::APIDailyUse.increase_for!("EDIT-RELAYLAP-#{current_user.id}")
    else
      @alert_msg = I18n.t('search_view.errors.submit_generic_failure')
      @alert_class = 'alert-danger'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # [XHR DELETE /relay_lap/:id] destroys an existing lap row.
  #
  # == Required Params:
  # - <tt>id</tt>: existing row ID
  #
  def destroy
    if @curr_lap&.destroy
      @alert_msg = I18n.t('laps.modal.msgs.destroy_successful')
      @alert_class = 'alert-success'
      GogglesDb::APIDailyUse.increase_for!("DELETE-RELAYLAP-#{current_user.id}")
    elsif @curr_lap
      @alert_msg = I18n.t('datagrid.edit_modal.delete_failed')
      @alert_class = 'alert-danger'
    else
      @alert_msg = I18n.t('search_view.errors.invalid_request')
      @alert_class = 'alert-warning'
    end

    check_and_set_lap_edit_and_report_mistake_flags # (Needs @relay_result to be set)
    render(:update)
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Strong parameters checking for main modal/header operations
  def modal_params
    params.permit(:authenticity_token, :result_id, :result_class, :badge_id, :length_in_meters)
  end

  # Strong parameters checking for all row actions
  def rows_params
    params.permit(
      :authenticity_token, :id, result_id: {}, result_class: {},
                                length_in_meters: {}, minutes_from_start: {}, seconds_from_start: {}, hundredths_from_start: {}
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the correct sibling class for the "parent result" (MRR or MRS), given the :result_class parameter
  # within the context of the modal dialog (1 parameter).
  def result_class_from_params
    return GogglesDb::MeetingRelayResult if modal_params[:result_class].to_s.include?('RelayResult')

    GogglesDb::MeetingRelaySwimmer
  end

  # Returns the correct sibling class for the lap, given the :result_class parameter
  # within the context of the modal dialog (1 parameter).
  def lap_class_from_params
    return GogglesDb::MeetingRelaySwimmer if modal_params[:result_class].to_s.include?('RelayResult')

    GogglesDb::RelayLap
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the correct sibling class for the "parent result" (MRR or MRS), given the :result_class parameter
  # within the context of the row forms (1 parameter x N rows).
  def result_class_from_row_params
    return GogglesDb::MeetingRelayResult if rows_params[:result_class]&.values&.first&.to_s&.include?('RelayResult')

    GogglesDb::MeetingRelaySwimmer
  end

  # Returns the correct sibling class for the lap, given the :result_class parameter
  # within the context of the row forms (1 parameter x N rows).
  def lap_class_from_row_params
    return GogglesDb::MeetingRelaySwimmer if rows_params[:result_class]&.values&.first&.to_s&.include?('RelayResult')

    GogglesDb::RelayLap
  end

  # Sets both @parent_result and @relay_result according to the result_class & lap_class specified.
  # (Different includes & MRR helper reference are required)
  def set_parent_and_relay_result_members(result_class, result_id)
    @parent_result = result_class.find_by(id: result_id)
    @relay_result = result_class == GogglesDb::MeetingRelayResult ? @parent_result : @parent_result&.meeting_relay_result
  end
  #-- -------------------------------------------------------------------------
  #++

  # Redirects to root setting a generic flash warning message
  def handle_invalid_request
    # @alert_msg is used inside the edit modal to show messages since flash is not displayable
    flash.now[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path) unless request.xhr?
  end

  # Redirects to root setting a generic flash error message
  def handle_error_request
    flash.now[:error] = I18n.t('search_view.errors.submit_generic_failure')
    redirect_to(root_path) unless request.xhr?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Validates the request type and the required parameters for the main modal operations.
  # Sets the <tt>@parent_result</tt> & <tt>@relay_result</tt> members.
  # Redirects to root_path otherwise.
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def validate_modal_request
    valid_params = request.xhr? && request.post? &&
                   modal_params[:result_id].present? &&
                   modal_params[:result_class].present? &&
                   result_class_from_params.exists?(modal_params[:result_id])
    handle_invalid_request && return unless valid_params

    set_parent_and_relay_result_members(result_class_from_params, modal_params[:result_id])
    handle_invalid_request && return unless @parent_result
  end

  # Validates the request type and the required parameters for a row update or delete.
  # Sets the <tt>@parent_result</tt> ,<tt>@relay_result</tt> & <tt>@curr_lap</tt> members.
  # Redirects to root_path otherwise.
  #
  def validate_row_request
    valid_params = request.xhr? && (request.put? || request.delete?) &&
                   rows_params[:id].present? &&
                   lap_class_from_row_params.exists?(rows_params[:id]) &&
                   rows_params[:result_id]&.values&.first&.present? &&
                   rows_params[:result_class]&.values&.first&.present? &&
                   result_class_from_row_params.exists?(rows_params[:result_id].values.first)
    handle_invalid_request && return unless valid_params

    set_parent_and_relay_result_members(result_class_from_row_params, rows_params[:result_id].values.first)
    @curr_lap = lap_class_from_row_params.find_by(id: rows_params[:id])
    handle_invalid_request && return unless @parent_result && @curr_lap
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # Returns a new model instance used for new lap row fields (dependent on the class
  # of the parent result).
  #
  # *REQUIRES* <tt>@parent_result</tt> to be already defined.
  #
  # == Params:
  # - <tt>length_in_meters</tt>: overall length in meters from the start for a MRS or
  #                              increment step in meters for a RelayLap
  # - <tt>relay_order</tt>: relay phase index, usually 1..4 (ignored by RelayLaps and used just by MRSs)
  #
  def new_zeroed_lap(length_in_meters, relay_order) # rubocop:disable Metrics/MethodLength
    if @parent_result.is_a?(GogglesDb::MeetingRelayResult)
      event_type = @parent_result.event_type
      stroke_type_id = if event_type.stroke_type_id == GogglesDb::StrokeType::REL_INTERMIXED_ID && relay_order.positive?
                         [
                           GogglesDb::StrokeType::BACKSTROKE_ID,
                           GogglesDb::StrokeType::BREASTSTROKE_ID,
                           GogglesDb::StrokeType::BUTTERFLY_ID,
                           GogglesDb::StrokeType::FREESTYLE_ID
                         ].at(relay_order - 1)
                       else
                         event_type.stroke_type_id
                       end
      badge = GogglesDb::Badge.find(modal_params[:badge_id].to_i)
      return GogglesDb::MeetingRelaySwimmer.new(
        meeting_relay_result_id: @parent_result.id,
        relay_order:,
        swimmer_id: badge.swimmer_id,
        badge_id: badge.id,
        stroke_type_id:,
        length_in_meters:,
        minutes: 0,
        seconds: 0,
        hundredths: 0,
        minutes_from_start: 0,
        seconds_from_start: 0,
        hundredths_from_start: 0
      )
    end

    # Else: @parent_result => GogglesDb::MeetingRelaySwimmer
    GogglesDb::RelayLap.new(
      meeting_relay_result_id: @relay_result.id,
      meeting_relay_swimmer_id: @parent_result.id,
      swimmer_id: @parent_result.swimmer_id,
      team_id: @relay_result.team_id,
      length_in_meters:,
      position: 0,
      minutes: 0,
      seconds: 0,
      hundredths: 0,
      minutes_from_start: 0,
      seconds_from_start: 0,
      hundredths_from_start: 0
    )
  end

  # Assuming @relay_result member has been setup,
  # this sets both the flags @lap_edit & @report_mistake by checking their current values.
  def check_and_set_lap_edit_and_report_mistake_flags
    return unless @relay_result # This can be nil when forging URL paths

    if @relay_result.respond_to?(:season)
      season_id = @relay_result.season.id
      update_user_teams_for_seasons_ids([season_id])
      update_managed_teams_for_seasons_ids([season_id])
    end

    @lap_edit = @managed_team_ids.nil? || @managed_team_ids.include?(@relay_result.team_id)
    @report_mistake = @lap_edit || (user_signed_in? && @user_teams.map(&:id).include?(@relay_result.team_id))
  end

  # Generic "previous lap" retrieval.
  # This should work for both MRS & RL, with or without any previous RL or MRS row existing.
  #
  # REQUIRES @relay_result to be already defined and assumes +edited_lap+ it's a sibling (MRS /RL).
  # Returns the *previous* lap or sub-lap for the specified edited_lap.
  #
  # == Params:
  # - edited_lap: the edited RelayLap or MRS instance
  def retrieve_generic_previous_lap(edited_lap)
    # RL without previous lap:
    return nil if edited_lap.is_a?(GogglesDb::RelayLap) && edited_lap.length_in_meters < 100

    # RL with a simple previous sub-lap (when found):
    if edited_lap.is_a?(GogglesDb::RelayLap)
      prev_lap = edited_lap.previous_lap
      return prev_lap if prev_lap.present?
    end

    # MRS & sub-laps existing? Use the previous one:
    return edited_lap.relay_laps.order(:length_in_meters)&.last if edited_lap.is_a?(GogglesDb::MeetingRelaySwimmer) && edited_lap.relay_laps.present?

    # MRS but no sub-laps OR RL w/o sub-laps? Return the previous MRS if any:
    @relay_result.meeting_relay_swimmers
                 .where('length_in_meters < ?', edited_lap.length_in_meters)
                 .order(:length_in_meters)
                 .last
    # NOTE: previous lap precedence => MRS over RL
    # (MRS are always longer that its own sub-laps because it's created as last closing lap round,
    # so the closest previous generic lap when no RL are available for the current fraction, will be
    # the preceding MRS.)
  end

  # Recomputes the delta timing values for a given +edited_lap+, which can be either a MRS or a RelayLap.
  #
  # REQUIRES @relay_result to be already defined and assumes +edited_lap+ it's a sibling (MRS /RL).
  # Returns the result of edited_lap.save.
  #
  # == Params:
  # - edited_lap: the edited RelayLap or MRS instance
  def recompute_delta_for!(edited_lap)
    # Generic "previous lap" retrieval: it should work for both MRS & RL, w/ or w/o previous RL or MRS:
    previous_lap = retrieve_generic_previous_lap(edited_lap)

    edited_lap_timing_from_start = if edited_lap.respond_to?(:timing_from_start)
                                     # If it's an AbstractLap, this helper allows to recompute the
                                     # timing_from_start using queries even if the value wasn't present:
                                     edited_lap.timing_from_start
                                   else
                                     # Fallback to standardized TimingManageable helper:
                                     edited_lap.to_timing(from_start: true)
                                   end
    previous_lap_timing_from_start = if previous_lap.respond_to?(:timing_from_start)
                                       previous_lap.timing_from_start
                                     elsif previous_lap
                                       previous_lap.to_timing(from_start: true)
                                     end
    # When there's no previous lap, the timing_from_start is the one from the current instance:
    delta_timing = previous_lap ? edited_lap_timing_from_start - previous_lap_timing_from_start : edited_lap.to_timing
    edited_lap.from_timing(delta_timing)
    edited_lap.save
  end

  # Loops on all relay laps (MRS) or sub-laps (RelayLap) following the +edited_lap+ and
  # recomputes the delta timing of each one found updating the row.
  #
  # REQUIRES @relay_result to be already defined.
  #
  # == Params:
  # - edited_lap: the edited RelayLap or MRS instance
  #
  # == Params:
  # +true+ on success, +false- at the first failure
  #
  def recompute_following_laps_timings!(edited_lap)
    starting_mrs = edited_lap.respond_to?(:meeting_relay_swimmer) ? edited_lap.meeting_relay_swimmer : edited_lap
    all_ok = true
    # Include the containing MRS in the external loop, but consider only laps greater than
    # the edited one (which could also be an MRS):
    @relay_result.meeting_relay_swimmers
                 .where('length_in_meters >= ?', starting_mrs.length_in_meters)
                 .order(:length_in_meters)
                 .each do |following_mrs|
      following_mrs.relay_laps
                   .order(:length_in_meters)
                   .where('relay_laps.length_in_meters > ?', edited_lap.length_in_meters)
                   .each do |following_rl|
        all_ok = recompute_delta_for!(following_rl)
        break unless all_ok
      end
      # Skip containing MRS if it was the edited lap:
      all_ok = recompute_delta_for!(following_mrs) if all_ok && following_mrs.length_in_meters != edited_lap.length_in_meters
      break unless all_ok
    end

    all_ok
  end
end
# rubocop:enable Metrics/ClassLength
