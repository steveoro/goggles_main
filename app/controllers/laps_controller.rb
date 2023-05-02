# frozen_string_literal: true

# = LapsController
#
# rubocop:disable Metrics/ClassLength
class LapsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_modal_request, only: %i[edit_modal create]
  before_action :validate_row_request, only: %i[update destroy]

  # [XHR POST /laps/edit_modal] renders the Laps edit modal for the specified result.
  #
  # == Constraints:
  # - 1 modal per page;
  # - same target DOM for rendering ('#lap-edit-modal-container');
  # - overwrites previous contents of the target DOM.
  #
  def edit_modal
    # (Won't render anything if the parent result is not found)
    last_lap = @parent_result.laps.by_distance.last
    @last_delta_timing = @parent_result.to_timing - last_lap.timing_from_start if last_lap
  end
  #-- -------------------------------------------------------------------------
  #++

  # [XHR POST /lap/create] creates a new, zeroed Lap model, appended as a new lap
  # form row to the HTML table.
  #
  # == Params:
  # - <tt>result_id</tt>: parent result ID (either a MIR or a user result)
  #
  # - <tt>result_class</tt>: parent result class name (GogglesDb::MeetingIndividualResult or GogglesDb::UserResult)
  #
  # - <tt>step</tt>: lap step length in meters; this will be appended to the last lap length to get the actual
  #   overall length of the new lap.
  #   The new row will be actually created and added to the list only if the resulting <tt>length_in_meters</tt>
  #   for this lap is < the length in meters of the parent result.
  #
  def create
    step_length = modal_params[:step].to_i

    # Create additional lap if requested:
    if step_length.positive?
      last_lap = @parent_result.laps.by_distance.last
      next_distance = step_length + last_lap&.length_in_meters.to_i
      return if next_distance >= @parent_result.event_type.length_in_meters

      handle_error_request unless new_zeroed_lap(next_distance).save
    end

    @alert_msg = I18n.t('laps.modal.msgs.create_successful')
    @last_delta_timing = @parent_result.to_timing - last_lap.timing_from_start if last_lap
    render(:update)
  end
  #-- -------------------------------------------------------------------------
  #++

  # [XHR PUT /lap/:id] updates an existing lap row given the parameters.
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
  #     "result_class"          => { "<ROW_INDEX>" => "GogglesDb::MeetingIndividualResult" },
  #     "id"                    => "<LAP_ID>",
  #     "length_in_meters"      => { "<ROW_INDEX>" => "150" },
  #     "minutes_from_start"    => { "<ROW_INDEX>" =>"3" },
  #     "seconds_from_start"    => { "<ROW_INDEX>" => "55" },
  #     "hundredths_from_start" => { "<ROW_INDEX>" => "10" },
  #   }
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def update
    # Update timing from start for current lap
    @curr_lap.length_in_meters = rows_params[:length_in_meters]&.values&.first || 0
    @curr_lap.minutes_from_start = rows_params[:minutes_from_start]&.values&.first || 0
    @curr_lap.seconds_from_start = rows_params[:seconds_from_start]&.values&.first || 0
    @curr_lap.hundredths_from_start = rows_params[:hundredths_from_start]&.values&.first || 0

    # Recompute current delta giving precedence to #timing_from_start:
    previous_lap = lap_class_from_row_params.related_laps(@curr_lap)
                                            .where('length_in_meters < ?', @curr_lap.length_in_meters)
                                            .last
    delta_timing = previous_lap ? @curr_lap.timing_from_start - previous_lap.timing_from_start : @curr_lap.timing_from_start
    @curr_lap.from_timing(delta_timing)
    handle_error_request unless @curr_lap.save

    # Recompute & update all subsequent deltas:
    following_laps = lap_class_from_row_params.related_laps(@curr_lap)
                                              .includes(
                                                result_class_from_row_params.table_name.singularize.to_sym,
                                                :swimmer, :event_type
                                              )
                                              .where('length_in_meters > ?', @curr_lap.length_in_meters)

    following_laps = following_laps.includes(:team) if @curr_lap.respond_to?(:team)
    following_laps.each do |lap|
      previous_lap = lap_class_from_row_params.related_laps(lap).where('length_in_meters < ?', lap.length_in_meters).last
      delta_timing = previous_lap ? lap.timing_from_start - previous_lap.timing_from_start : lap.timing_from_start
      lap.from_timing(delta_timing)
      handle_error_request unless lap.save
    end

    @alert_msg = I18n.t('laps.modal.msgs.submit_successful')
    last_lap = @parent_result.laps.by_distance.last
    @last_delta_timing = @parent_result.to_timing - last_lap.timing_from_start if last_lap
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #-- -------------------------------------------------------------------------
  #++

  # [XHR DELETE /lap/:id] destroys an existing lap row.
  #
  # == Required Params:
  # - <tt>id</tt>: existing row ID
  #
  def destroy
    handle_error_request unless @curr_lap.destroy

    @alert_msg = I18n.t('laps.modal.msgs.destroy_successful')
    last_lap = @parent_result.laps.by_distance.last
    @last_delta_timing = @parent_result.to_timing - last_lap.timing_from_start if last_lap
    render(:update)
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Strong parameters checking the main modal/header operations
  def modal_params
    params.permit(:authenticity_token, :result_id, :result_class, :step, :show_category, :show_team)
  end

  # Strong parameters checking all row actions
  def rows_params
    params.permit(:authenticity_token, :id, result_id: {}, result_class: {}, show_category: {}, show_team: {},
                                            length_in_meters: {}, minutes_from_start: {}, seconds_from_start: {}, hundredths_from_start: {})
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the correct sibling class for the AbstractResult, given the :result_class parameter
  # within the context of the modal dialog (1 parameter).
  def result_class_from_params
    return GogglesDb::MeetingIndividualResult if modal_params[:result_class].to_s.include?('IndividualResult')

    GogglesDb::UserResult
  end

  # Returns the correct sibling class for the AbstractLap, given the :result_class parameter
  # within the context of the modal dialog (1 parameter).
  def lap_class_from_params
    return GogglesDb::Lap if modal_params[:result_class].to_s.include?('IndividualResult')

    GogglesDb::UserLap
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the correct sibling class for the AbstractResult, given the :result_class parameter
  # within the context of the row forms (1 parameter x N rows).
  def result_class_from_row_params
    return GogglesDb::MeetingIndividualResult if rows_params[:result_class]&.values&.first&.to_s&.include?('IndividualResult')

    GogglesDb::UserResult
  end

  # Returns the correct sibling class for the AbstractLap, given the :result_class parameter
  # within the context of the row forms (1 parameter x N rows).
  def lap_class_from_row_params
    return GogglesDb::Lap if rows_params[:result_class]&.values&.first&.to_s&.include?('IndividualResult')

    GogglesDb::UserLap
  end
  #-- -------------------------------------------------------------------------
  #++

  # Redirects to root setting a generic flash warning message
  def handle_invalid_request
    flash[:warning] = I18n.t('search_view.errors.invalid_request')
    redirect_to(root_path) && return
  end

  # Redirects to root setting a generic flash error message
  def handle_error_request
    flash[:error] = I18n.t('search_view.errors.submit_generic_failure')
    redirect_to(root_path) && return
  end
  #-- -------------------------------------------------------------------------
  #++

  # Validates the request type and the required parameters for the main modal operations.
  # Sets the <tt>@parent_result</tt> member.
  # Redirects to root_path otherwise.
  #
  # rubocop:disable Metrics/AbcSize
  def validate_modal_request
    handle_invalid_request unless request.xhr? && request.post? && modal_params[:result_id].present? &&
                                  modal_params[:result_class].present? &&
                                  result_class_from_params.exists?(modal_params[:result_id])

    # Display customizations for the parent MIR component from pass-through parameters:
    @show_category = modal_params[:show_category]
    @show_team = modal_params[:show_team]

    @parent_result = result_class_from_params.includes(lap_class_from_params.table_name.to_sym, :event_type)
                                             .find_by(id: modal_params[:result_id])
  end
  # rubocop:enable Metrics/AbcSize

  # Validates the request type and the required parameters for a row update or delete.
  # Sets both <tt>@parent_result</tt> & <tt>@curr_lap</tt> members.
  # Redirects to root_path otherwise.
  #
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def validate_row_request
    handle_invalid_request unless request.xhr? && (request.put? || request.delete?) && rows_params[:id].present? &&
                                  lap_class_from_row_params.exists?(rows_params[:id]) &&
                                  rows_params[:result_id]&.values&.first&.present? &&
                                  rows_params[:result_class]&.values&.first&.present? &&
                                  result_class_from_row_params.exists?(rows_params[:result_id].values.first)

    # Display customizations for the parent MIR component from pass-through parameters:
    @show_category = rows_params[:show_category]&.values&.first == '1' || false
    @show_team = rows_params[:show_team]&.values&.first == '1' || rows_params[:show_team]&.values&.first.nil? # default: true

    # Required row request members:
    @curr_lap = lap_class_from_row_params.find_by(id: rows_params[:id])
    @parent_result = result_class_from_row_params.includes(lap_class_from_row_params.table_name.to_sym, :event_type)
                                                 .find_by(id: rows_params[:result_id].values.first)
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
  # - <tt>length_in_meters</tt>: overall length in meters from the start
  #
  def new_zeroed_lap(length_in_meters)
    if @parent_result.is_a?(GogglesDb::MeetingIndividualResult)
      return GogglesDb::Lap.new(
        meeting_individual_result_id: @parent_result.id,
        meeting_program_id: @parent_result.meeting_program_id,
        swimmer_id: @parent_result.swimmer_id,
        team_id: @parent_result.team_id,
        length_in_meters: length_in_meters,
        minutes: 0,
        seconds: 0,
        hundredths: 0,
        minutes_from_start: 0,
        seconds_from_start: 0,
        hundredths_from_start: 0
      )
    end

    GogglesDb::UserLap.new(
      user_result_id: @parent_result.id,
      swimmer_id: @parent_result.swimmer_id,
      length_in_meters: length_in_meters,
      minutes: 0,
      seconds: 0,
      hundredths: 0,
      minutes_from_start: 0,
      seconds_from_start: 0,
      hundredths_from_start: 0
    )
  end
end
# rubocop:enable Metrics/ClassLength
