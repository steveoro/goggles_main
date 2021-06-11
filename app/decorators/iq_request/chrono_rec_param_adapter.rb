# frozen_string_literal: true

# = IqRequest
# Wrapper module for all request decorators concering ImportQueues.
#
module IqRequest
  # = IqRequest::ChronoRecParamAdapter
  #
  # Given a source data hash, this class prepares & maps the hashed parameters
  # that will be JSON-ified and saved as the actual content for a GogglesDb::ImportQueue#request_data.
  # (It's more of a mapper than an actual decorator.)
  #
  # Check out the supported key values for the source parameter params in #SUPPORTED_PARAMS.
  #
  # == Special parameters:
  #
  # 'rec_type' discriminates with its value the actual type of /chrono/rec request build-up.
  #
  #  1. Switch::XorComponent::TYPE_TARGET1 => Meeting
  #  2. Switch::XorComponent::TYPE_TARGET2 => UserWorkshop
  #
  # Given the entity hierachy, the actual target of the request will depend of that value.
  # (In the case of a Meeting => Lap, in the case of a UserWorkshop => UserLap.)
  #
  # For most other entity definition value that may be shared "in between" association,
  # like in the case of a SwimmingPool definition, these will be mostly set at root depth
  # in the resulting hash so that these are reused as defaults for any other missing associations.
  #
  # Most shared column values are also kept on root level on purpose.
  # For example, the event_date can be shared as setting value between a MeetingSession
  # and its correlated Meeting definition.
  #
  # Whenever an id field is not present or set to 0, if the specified values
  # aren't enough to pick an existing row, a new one will be scheduled for
  # creation if the overall request can be resolved.
  #
  # @see any Solver class for more info.
  #
  # rubocop:disable Metrics/ClassLength
  class ChronoRecParamAdapter
    # Source parameters Hash; supports all SUPPORTED_PARAMS.keys
    attr_reader :params

    # Detail data row Hash for the chrono recording; supports all REC_DETAIL_PARAMS.keys
    attr_reader :rec_data

    # Request_hash accessor, mainly used in self.from_request_data
    attr_accessor :request_hash

    # Allowed params for building the request data Hash.
    # Entity names act as snake-case namespaces for the actual fields or column values.
    SUPPORTED_PARAMS = %w[
      rec_type
      meeting_id meeting_label meeting_code meeting_header_date
      workshop_id workshop_label workshop_code workshop_header_date workshop_edition workshop_edition_type_id
      event_date header_year
      season_id season_description season_begin_date season_end_date season_edition
      season_type_id season_edition_type_id
      swimming_pool_id swimming_pool_label swimming_pool_name swimming_pool_nick_name
      swimming_pool_city_id swimming_pool_pool_type_id
      pool_type_id pool_type_label
      event_type_id event_type_label
      swimmer_id swimmer_label swimmer_complete_name swimmer_first_name swimmer_last_name
      swimmer_year_of_birth swimmer_gender_type_id
      team_id team_label team_name team_editable_name team_city_id
      category_type_id category_type_label
      city_id city_name city_country_code
    ].freeze

    # Allowed detail keys for the rec-data hash
    REC_DETAIL_PARAMS = %w[
      order label length_in_meters reaction_time minutes seconds hundredths position
      minutes_from_start seconds_from_start hundredths_from_start
    ].freeze

    # Creates the params adapter, targeted at preparing an ImportQueue#request_data.
    #
    # == Params:
    # - current_user: GogglesDb::User instance representing the user making the request.
    #
    # - params_hash: source parameter Hash acting as main data header for all the available attributes.
    #                (See +SUPPORTED_PARAMS+ list)
    #
    # - rec_data_hash: source detail parameter Hash with stringified keys, defining all
    #                  the available lap/user_lap attributes (default: {})
    #
    def initialize(current_user, params_hash, rec_data_hash = {})
      valid_params = current_user.is_a?(GogglesDb::User) &&
                     (params_hash.is_a?(Hash) || params_hash.is_a?(ActionController::Parameters))
      raise(ArgumentError, 'Invalid source params Hash or current_user instance') unless valid_params

      @params = params_hash
      @rec_data = rec_data_hash
      @current_user = current_user
    end

    # Creates the params adapter directly from the JSON stored inside ImportQueue#request_data.
    #
    # == Params:
    # - request_data: valid JSON text describing the request hash
    #
    def self.from_request_data(request_data)
      request_hash = ActiveSupport::JSON.decode(request_data)
      # Fail fast here: do not catch errors. Either the request is already well formed or not,
      # in which case, we shouldn't proceed.

      # Find the user_id if present (fail fast if it's neither @ root level nor nested)
      user_id = request_hash.fetch('user_id', nil) ||
                request_hash.fetch('user_lap', nil)&.fetch('user_result', nil)&.fetch('user_id', nil)
      instance = IqRequest::ChronoRecParamAdapter.new(GogglesDb::User.find_by_id(user_id), {})
      instance.request_hash = request_hash
      instance
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns the unnamespaced, camelcase name of the target entity.
    # (i.e. 'UserLap' and not 'GogglesDb::UserLap')
    def target_entity
      rec_type_workshop? ? 'UserLap' : 'Lap'
    end

    # Returns the root-level key of the request hash, according to the 'target_entity' value.
    def root_key
      target_entity.tableize.singularize
    end

    # Similarly to root_key, returns the first-depth parent key of the request hash according to the 'target_entity' value.
    def result_parent_key
      rec_type_workshop? ? 'user_result' : 'meeting_individual_result'
    end

    # Similarly to #root_key, returns the request Hash depending on the target entity,
    # without its root_key.
    def root_request_hash
      return @request_hash[root_key] if @request_hash.present?

      return user_lap_attr if rec_type_workshop?

      {
        # TODO: lap_attr + all nested hierarchy (& solvers)
      }
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns the request Hash adapted from the specified constructor parameters.
    def to_request_hash
      return @request_hash if @request_hash.present?

      {
        'target_entity' => target_entity,
        root_key => root_request_hash
      }
    end

    # Updates the internal request hash representation by setting the individual fields of the
    # destination root_key with the specified hash of values.
    # @see REC_DETAIL_PARAMS for the list of supported keys (stringified). Keys will only be updated
    # if supported and not empty.
    #
    # == Example:
    # - root_key = 'lap'
    # - rec_data_hash = { 'order' => 1, 'minutes' => 0, 'seconds' => '31', 'hundredths' => '23' }
    # - result => { 'lap' => <existing keys merged with rec_data_hash> }
    #
    def update_rec_detail_data(rec_data_hash)
      if @request_hash.present?
        REC_DETAIL_PARAMS.each do |key|
          # Avoid setting missing keys:
          @request_hash[root_key][key] = rec_data_hash[key] if rec_data_hash.key?(key)
        end
      end
      return unless @rec_data.present?

      REC_DETAIL_PARAMS.each { |key| @rec_data[root_key][key] = rec_data_hash[key] if rec_data_hash.key?(key) }
    end

    # Updates the internal request hash representation with the total timing specified in the rec_data_hash.
    # When recording multiple laps for the same result, the last lap timing is usually assumed to be
    # the overall result timing of the race (unless a lap timing has been skipped for any reason).
    # Supports the same fields as #update_rec_detail_data. Keys will only be updated if supported and not empty.
    #
    # == Example:
    # - root_key = 'lap'
    # - rec_data_hash = { 'order' => 1, 'minutes' => 0, 'seconds' => '31', 'hundredths' => '23' }
    # - result => { 'lap' => { 'meeting_individual_result' => <existing keys merged with rec_data_hash> } }
    #
    def update_result_data(rec_data_hash)
      if @request_hash.present?
        REC_DETAIL_PARAMS.each do |key|
          # Avoid setting missing keys:
          @request_hash[root_key][result_parent_key][key] = rec_data_hash[key] if rec_data_hash.key?(key)
        end
      end
      return unless @rec_data.present?

      REC_DETAIL_PARAMS.each { |key| @rec_data[root_key][result_parent_key][key] = rec_data_hash[key] if rec_data_hash.key?(key) }
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns the 'header_year' field if present or tries to build one
    # given the event date.
    def header_year
      return @request_hash['header_year'] if @request_hash.present?

      return @params['header_year'] if @params['header_year'].present?

      year = /\d{4}/.match(@params['event_date'].to_s).values_at(0).first.to_i
      month = begin
        Date.parse(@params['event_date']).month
      rescue Date::Error
        0
      end
      month > 8 ? "#{year}/#{year + 1}" : "#{year - 1}/#{year}"
    end

    # Returns +true+ if the request data is a Meeting recording
    def rec_type_meeting?
      return @request_hash.present? && @request_hash['target_entity'] == 'Lap' if @request_hash.present?

      @params['rec_type'].to_i == Switch::XorComponent::TYPE_TARGET1
    end

    # Returns +true+ if the request data is a Workshop recording
    def rec_type_workshop?
      return @request_hash.present? && @request_hash['target_entity'] == 'UserLap' if @request_hash.present?

      @params['rec_type'].to_i == Switch::XorComponent::TYPE_TARGET2
    end
    #-- -----------------------------------------------------------------------
    #++

    private

    # Maps the source params Hash into Season def. attributes, without the root key ('season').
    def season_attr
      return @request_hash['season'] if @request_hash.present?

      {
        'id' => @params['season_id'],
        'description' => @params['season_description'],
        'begin_date' => @params['season_begin_date'],
        'end_date' => @params['season_end_date'],
        'edition' => @params['season_edition'],
        'season_type_id' => @params['season_type_id'],
        'edition_type_id' => @params['season_edition_type_id']
      }
    end

    # Maps the source params Hash into Swimmer def. attributes, without the root key ('swimmer').
    def swimmer_attr
      return @request_hash['swimmer'] if @request_hash.present?

      {
        'id' => @params['swimmer_id'],
        'label' => @params['swimmer_label'],
        'first_name' => @params['swimmer_first_name'],
        'last_name' => @params['swimmer_last_name'],
        'complete_name' => @params['swimmer_complete_name'],
        'year_of_birth' => @params['swimmer_year_of_birth'],
        'gender_type_id' => @params['swimmer_gender_type_id']
      }
    end

    # Maps the source params Hash into SwimmingPool def. attributes, without the root key ('swimming_pool').
    def swimming_pool_attr
      return @request_hash['swimming_pool'] if @request_hash.present?

      {
        'id' => @params['swimming_pool_id'],
        'label' => @params['swimming_pool_label'],
        'name' => @params['swimming_pool_name'],
        'nick_name' => @params['swimming_pool_nick_name']
      }
    end

    # Maps the source params Hash into Team def. attributes, without the root key ('team').
    def team_attr
      return @request_hash['team'] if @request_hash.present?

      {
        'id' => @params['team_id'],
        'label' => @params['team_label'],
        'name' => @params['team_name'],
        'editable_name' => @params['team_editable_name'],
        'city_id' => @params['team_city_id']
      }
    end

    # Maps the source params Hash into UserWorkshop def. attributes, without the root key ('user_workshop').
    def user_workshop_attr
      return @request_hash['user_workshop'] if @request_hash.present?

      {
        'id' => @params['workshop_id'],
        'description' => @params['workshop_label'],
        'code' => @params['workshop_code'],
        'header_date' => @params['workshop_header_date'] || @params['event_date'],
        'header_year' => header_year,
        'edition' => @params['workshop_edition'],
        'edition_type_id' => @params['workshop_edition_type_id'],
        'user_id' => @current_user.id,
        'team' => team_attr,
        'season' => season_attr,
        'swimming_pool' => swimming_pool_attr
      }
    end

    # Maps the source params Hash into UserResult definition attributes, without the root key ('user_result').
    def user_result_attr
      return @request_hash['user_result'] if @request_hash.present?

      {
        'id' => @params['user_result_id'],
        'user_workshop' => user_workshop_attr,
        'user_id' => @current_user.id,
        'swimmer' => swimmer_attr,
        'category_type_id' => @params['category_type_id'],
        'pool_type_id' => @params['pool_type_id'] || @params['swimming_pool_id'],
        'event_type_id' => @params['event_type_id'],
        'event_date' => @params['event_date'] || @params['workshop_header_date']
      }
    end

    # Maps the source params Hash into UserLap definition attributes, without the root key ('user_lap').
    def user_lap_attr
      return @request_hash['user_lap'] if @request_hash.present?

      {
        'id' => @params['user_lap_id'],
        'user_result' => user_result_attr,
        'swimmer' => swimmer_attr,
        'label' => @rec_data['label'],
        'order' => @rec_data['order'],
        'length_in_meters' => @rec_data['length_in_meters'],
        'reaction_time' => @rec_data['reaction_time'],
        'minutes' => @rec_data['minutes'],
        'seconds' => @rec_data['seconds'],
        'hundredths' => @rec_data['hundredths'],
        'position' => @rec_data['position'],
        'minutes_from_start' => @rec_data['minutes_from_start'],
        'seconds_from_start' => @rec_data['seconds_from_start'],
        'hundredths_from_start' => @rec_data['hundredths_from_start']
      }
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  # rubocop:enable Metrics/ClassLength
end
