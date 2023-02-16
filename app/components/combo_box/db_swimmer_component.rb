# frozen_string_literal: true

#
# = ComboBox components module
#
#   - version:  7-0.4.25
#   - author:   Steve A.
#
module ComboBox
  #
  # = ComboBox::DbSwimmerComponent
  #
  # Creates a Select2-based combo-box, with AJAX retrieval of the datasource,
  # using the StimulusJS LookupController.
  #
  # This sibling version is tailored to handle GogglesDb::Swimmer extra data fields
  # as hidden_field tags.
  #
  # @see ComboBox::DbLookupComponent
  #
  class DbSwimmerComponent < DbLookupComponent
    # Creates a new ViewComponent
    #
    # == Params:
    # - label.......: text label displayed on top of the select field
    #
    # - base_name...: base name for the form & table fields of this widget;
    #   Any <BASE_NAME> set (e.g. 'meeting') will use:
    #   - '<BASE_NAME>_id'     => ('meeting_id') hidden form field DOM ID for the selected *id* value
    #   - '<BASE_NAME>_label'  => ('meeting_label') hidden form field DOM ID for the selected *text/label* value
    #   - '<BASE_NAME>'        => ('meeting') Select2 widget name
    #   - '<BASE_NAME>_select' => ('meeting_select') Select2 widget DOM ID
    #
    #   'base_name' is also used for:
    #   - "#{@base_name}-presence", the DOM node that acts as a flag for the hidden fields value presence.
    #     Visibility of this "flag" is managed by the associated StimulusJS LookupController.
    #
    #   - "#{@base_name}-new", the DOM node that acts as a "new" icon in case the db-lookup request doesn't find
    #     any match; managed (as above) by the associated Stimulus controller.
    #
    #
    # == Supported options & defaults:
    # - values: nil               => pre-existing array of Swimmers that will be mapped to the select options
    #                                (no need to use +options_for_select+ or +options_from_collection_for_select+ here);
    #                                when given, this will disable API usage.
    #
    # - default_row: nil          => pre-selected Swimmer for the input box
    #
    # - use_2_api: false          => toggles secondary API call to retrieve more entity details
    #
    # - free_text: false          => allows/disables free text as input
    #
    # - required: false           => sets the HTML5 'required' attribute for the select field
    #
    # - disabled: false           => sets the HTML5 'disabled' attribute for the select field
    #
    # - query_column: 'name'      => column name used for the API query call (default: 'name')
    #
    # - wrapper_class: 'col-auto' => CSS class for the wrapping DIV
    #
    def initialize(label, base_name, options = {})
      super(options[:values].present? ? nil : 'swimmers', label, base_name, options)

      @gender_types = [GogglesDb::GenderType.male, GogglesDb::GenderType.female]
      @default_row = SwimmerDecorator.decorate(options[:default_row]) if options[:default_row].instance_of?(GogglesDb::Swimmer)
      @values = options[:values]&.map { |swimmer| SwimmerDecorator.decorate(swimmer) }
    end

    protected

    # Returns the options list whenever there's a list of available selection row values,
    # using @default_row for preselection.
    # rubocop:disable Rails/OutputSafety
    def select_options_with_preselection
      return unless @values || @default_row

      if @default_row && @values.blank?
        return content_tag(
          :option,
          @default_row.text_label,
          selected: 'selected',
          value: @default_row.id.to_i,
          'data-complete_name': @default_row.complete_name,
          'data-first_name': @default_row.first_name,
          'data-last_name': @default_row.last_name,
          'data-year_of_birth': @default_row.year_of_birth,
          'data-gender_type_id': @default_row.gender_type_id
        )
      end

      # NOTE: each content_tag must include the additional data-field values for the lookups (given the API is disabled by
      #       the list of supplied values), so that the callbacks for the onchange event will update the hidden fields
      #       and all other associated form inputs.
      html_options = @values.map do |swimmer|
        content_tag(
          :option,
          swimmer.text_label,
          selected: swimmer.id == @default_row&.id ? 'selected' : nil,
          value: swimmer.id.to_i,
          'data-complete_name': swimmer.complete_name,
          'data-first_name': swimmer.first_name,
          'data-last_name': swimmer.last_name,
          'data-year_of_birth': swimmer.year_of_birth,
          'data-gender_type_id': swimmer.gender_type_id
        )
      end
      html_options.join("\r\n").html_safe
    end
    # rubocop:enable Rails/OutputSafety

    # Returns the option item list for GenderType selection
    def gender_type_options
      options_from_collection_for_select(
        @gender_types,
        'id',
        'label',
        @default_row&.gender_type_id || GogglesDb::GenderType.male.id
      )
    end
  end
end
