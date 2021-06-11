# frozen_string_literal: true

#
# = ComboBox components module
#
#   - version:  7.02
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
    #   'base_name' is also used for "#{@base_name}-presence", the DOM node that acts
    #   as a flag for the hidden fields value presence. Visibility of this "flag" is managed by
    #   the StimulusJS LookupController.
    #
    #
    # == Supported options & defaults:
    # - default_row: nil          => pre-selected Swimmer for the input box
    #
    # - free_text: false          => allows/disables free text as input
    #
    # - required: false           => sets the HTML5 'required' attribute for the select field
    #
    # - query_column: 'name'      => column name used for the API query call (default: 'name')
    #
    # - wrapper_class: 'col-auto' => CSS class for the wrapping DIV
    #
    def initialize(label, base_name, options = {})
      super('swimmers', label, base_name, options)
      return unless options[:default_row].instance_of?(GogglesDb::Swimmer)

      @default_row = SwimmerDecorator.decorate(options[:default_row])
    end

    protected

    # Returns the preselected option item if a default entity instance is
    # specified in the constructor
    def preselected_option
      return unless @default_row

      content_tag(
        :option,
        @default_row.text_label,
        selected: 'selected',
        value: @default_row.id,
        'data-complete_name': @default_row.complete_name,
        'data-first_name': @default_row.first_name,
        'data-last_name': @default_row.last_name,
        'data-year_of_birth': @default_row.year_of_birth,
        'data-gender_type_id': @default_row.gender_type_id
      )
    end
  end
end
