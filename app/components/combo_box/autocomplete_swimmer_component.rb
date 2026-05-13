# frozen_string_literal: true

module ComboBox
  # ViewComponent for rendering a swimmer autocomplete input field.
  class AutocompleteSwimmerComponent < ViewComponent::Base
    # Initialize the component with the given options.
    #
    # @param label [String] The label for the input field.
    # @param base_name [String] The base name for the input field.
    # @param options [Hash] Additional options for the component.
    #
    # == Options:
    # - :free_text [Boolean] Whether to allow free text input.
    # - :required [Boolean] Whether the field is required.
    # - :disabled [Boolean] Whether the field is disabled.
    # - :use_2_api [Boolean] Whether to use the second API.
    # - :query_column [String] The column to query.
    # - :wrapper_class [String] The class for the wrapper.
    # - :default_row [GogglesDb::Swimmer] The default row to preselect.
    # - :values [Array<GogglesDb::Swimmer>] The values to display in the dropdown.
    #
    def initialize(label, base_name, options = {}) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      @api_endpoint = options[:values].present? ? nil : 'swimmers'
      @label = label
      @base_name = base_name
      @free_text = options[:free_text] || false
      @required = options[:required] || false
      @disabled = options[:disabled] || false
      @use_2_api = options[:use_2_api] || false
      @query_column = options[:query_column] || 'name'
      @wrapper_class = options[:wrapper_class] || 'col-auto'

      @gender_types = [GogglesDb::GenderType.male, GogglesDb::GenderType.female]
      @default_row = SwimmerDecorator.decorate(options[:default_row]) if options[:default_row].instance_of?(GogglesDb::Swimmer)
      @values = GogglesDb::SwimmerDecorator.decorate_collection(options[:values]) if options[:values]
    end

    protected

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

      html_options = @values.map do |swimmer|
        content_tag(
          :option,
          swimmer.display_label,
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
