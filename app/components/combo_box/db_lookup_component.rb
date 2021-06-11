# frozen_string_literal: true

#
# = ComboBox components module
#
#   - version:  7.02
#   - author:   Steve A.
#
module ComboBox
  #
  # = ComboBox::DbLookupComponent
  #
  # Creates a Select2-based combo-box, with AJAX retrieval of the datasource,
  # using the StimulusJS LookupController.
  #
  # Includes / supports:
  # - free-text entering
  # - hidden ID & Label fields that can be processed by a wrapping form
  # - required field toggle
  # - custom lookup query column name
  #
  class DbLookupComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params:
    # - api_url.....: API endpoint name to be used (i.e.: '/lookup/event_types' or '/meetings');
    #                 the base API URL is taken from the settings, appended with the common 'api/v3';
    #                 when the endpoint is set to nil, only the specified option[:values] will be used
    #
    # - label.......: text label displayed on top of the select field
    #
    # - base_name...: base name for the form & table fields of this widget;
    #   Any <BASE_NAME> set (e.g. 'meeting') will use:
    #   - '<BASE_NAME>_id'     => ('meeting_id') *hidden* form field DOM ID for the selected *id* value
    #   - '<BASE_NAME>_label'  => ('meeting_label') *hidden* form field DOM ID for the selected *text/label* value
    #   - '<BASE_NAME>'        => ('meeting') Select2 widget name
    #   - '<BASE_NAME>_select' => ('meeting_select') Select2 widget DOM ID
    #
    #   'base_name' is also used for "#{@base_name}-presence", the DOM node that acts
    #   as a flag for the hidden fields value presence. Visibility of this "flag" is managed by
    #   the StimulusJS LookupController.
    #
    #
    # == Supported options & defaults:
    # - values: nil               => pre-existing options for select (which may include default selection)
    #                                (either use +options_for_select+ or +options_from_collection_for_select+)
    #
    # - use_2_api: false          => toggles secondary API call to retrieve more entity details
    #
    # - free_text: false          => allows/disables free text as input
    #
    # - required: false           => sets the HTML5 'required' attribute for the select field
    #
    # - query_column: 'name'      => column name used for the API query call (default: 'name')
    #
    # - bound_query_param:        => DOM ID for a field holding the value for a same-named, additional API query parameter
    #
    # - wrapper_class: 'col-auto' => CSS class for the wrapping DIV
    #
    def initialize(api_url, label, base_name, options = {})
      super
      @api_url = api_url.present? ? "#{base_api_url}/api/v3/#{api_url}" : nil
      @api_url2 = "#{base_api_url}/api/v3" if options[:use_2_api] # Toggle secondary call by setting the shared base URL
      @label = label
      @base_name = base_name
      @free_text = options[:free_text] || false
      @required = options[:required] || false
      @query_column = options[:query_column] || 'name'
      @bound_query_param = options[:bound_query_param]
      @wrapper_class = options[:wrapper_class] || 'col-auto'
      @values = options[:values]
    end

    # Returns the base API URL for all endpoints
    def base_api_url
      GogglesDb::AppParameter.config.settings(:framework_urls).api
    end

    # Returns the placeholder text depending on the constructor parameters
    def placeholder_text
      @free_text ? I18n.t('lookup.placeholder_free') : I18n.t('lookup.placeholder')
    end
  end
end
