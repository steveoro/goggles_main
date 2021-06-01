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

  # [GET] Lists the queue of pending lap registrations by the current_user
  def index
    @queues = GogglesDb::ImportQueue.for_user(current_user)
  end
  #-- -------------------------------------------------------------------------
  #++

  # [GET] Form entry for preparing a new lap-recording micro-transaction
  def new
    # logger.debug("\r\n\r\n#{params.inspect}\r\n")
    # Prepare pool_types, event_types & latest category_types belonging to the
    # last available FIN season for current_user:
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
    # logger.debug("\r\n\r\n#{params.inspect}\r\n")
    set_rec_data_members
  end
  #-- -------------------------------------------------------------------------
  #++

  # [POST] Store a new lap-recording micro-transaction
  def commit
    # DEBUG
    # logger.debug("\r\n\r\n#{params.inspect}\r\n")
    header_data, lap_data = begin
      [
        ActiveSupport::JSON.decode(commit_params[:header] || ''),
        ActiveSupport::JSON.decode(commit_params[:payload] || '')
      ]
    rescue ActiveSupport::JSON.parse_error
      nil
    end

    if header_data.present? && lap_data.present?
      # DEBUG
      logger.debug("\r\n- Laps: #{lap_data.inspect}")
      GogglesDb::ImportQueue.create!(
        user: current_user,
        uid: 'chrono',
        request_data: header_data.merge(details: lap_data).to_json,
        solved_data: '{}'
      )
      flash[:notice] = t('chrono.messages.post_done')
    else
      flash[:error] = t('chrono.messages.post_error')
    end

    redirect_to(chrono_index_path)
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Allowed params for both /rec & /commit
  PERMITTED_PARAMS = %i[
    rec_type
    meeting_id meeting_label workshop_id workshop_label
    swimming_pool_id swimming_pool_label
    pool_type_id pool_type_label
    event_date event_type_id event_type_label
    swimmer_id swimmer_label
    category_type_id category_type_label
  ].freeze

  # Strong parameter checking for POST /rec
  def rec_params
    params.permit(PERMITTED_PARAMS + %i[authenticity_token commit])
  end

  # Strong parameter checking for POST /commit
  def commit_params
    params.permit(%i[header payload authenticity_token commit])
  end

  # Checks that the user selected either valid IDs or new names for a Meeting or a Workshop.
  # Redirects to /new otherwise.
  def validate_rec_params
    return if (rec_type_meeting? || rec_type_workshop?) &&
              (rec_params[:meeting_label].present? || rec_params[:workshop_label].present?)

    flash[:error] = I18n.t('chrono.messages.error.missing_meeting_or_workshop_name')
    redirect_to(chrono_new_path)
  end

  # Validates presence of required /commit parameters.
  # Redirects to /new otherwise.
  def validate_commit_params
    return if commit_params[:header].present? && commit_params[:payload].present?

    flash[:error] = I18n.t('chrono.messages.error.commit_missing_parameters')
    redirect_to(chrono_new_path)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepares all the member variables for a new recording given the current rec_params.
  def set_rec_data_members
    # Prepare members:
    PERMITTED_PARAMS.each do |param_key|
      instance_variable_set("@#{param_key}", rec_params[param_key])
    end
    # Prepare header:
    header_hash = if rec_type_meeting?
                    {
                      target_entity: 'MeetingIndividualResult',
                      meeting: { id: @meeting_id, label: @meeting_label }
                    }
                  else
                    {
                      target_entity: 'UserResult',
                      user_workshop: { id: @workshop_id, label: @workshop_label }
                    }
                  end
    header_hash.merge!(
      {
        event_date: @event_date,
        swimming_pool: { id: @swimming_pool_id, label: @swimming_pool_label },
        pool_type_id: @pool_type_id,
        event_type_id: @event_type_id,
        swimmer: { id: @swimmer_id, complete_name: @swimmer_label },
        category_type_id: @category_type_id
      }
    )
    @header_payload = header_hash.to_json
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns +true+ if the /rec params have requested a Meeting recording
  def rec_type_meeting?
    rec_params[:rec_type].to_i == Switch::XorComponent::TYPE_TARGET1
  end

  # Returns +true+ if the /rec params have requested a Workshop recording
  def rec_type_workshop?
    rec_params[:rec_type].to_i == Switch::XorComponent::TYPE_TARGET2
  end

  # Unused:

  # Returns +true+ if the /rec params include a new Meeting description
  # def new_meeting?
  #   rec_params[:meeting_label].present? && rec_params[:meeting_id].to_i.zero?
  # end

  # # Returns +true+ if the /rec params include a new Workshop description
  # def new_workshop?
  #   rec_params[:workshop_label].present? && rec_params[:workshop_id].to_i.zero?
  # end
  #-- -------------------------------------------------------------------------
  #++
end
