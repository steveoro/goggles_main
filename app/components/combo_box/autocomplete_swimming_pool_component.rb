# frozen_string_literal: true

module ComboBox
  # ViewComponent for rendering a swimming pool autocomplete input field.
  class AutocompleteSwimmingPoolComponent < ViewComponent::Base
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
    # - :default_row [GogglesDb::SwimmingPool] The default row to preselect.
    #
    def initialize(label, base_name, options = {})
      @label = label
      @base_name = base_name
      @free_text = options[:free_text] || false
      @required = options[:required] || false
      @disabled = options[:disabled] || false
      @use_2_api = options[:use_2_api] || false
      @query_column = options[:query_column] || 'name'
      @wrapper_class = options[:wrapper_class] || 'col-auto'

      return unless options[:default_row].instance_of?(GogglesDb::SwimmingPool)

      @default_row = SwimmingPoolDecorator.decorate(options[:default_row])
    end

    protected

    def preselected_option
      return unless @default_row

      content_tag(
        :option,
        @default_row.text_label,
        selected: 'selected',
        value: @default_row.id.to_i,
        'data-name': @default_row.name,
        'data-nick_name': @default_row.nick_name,
        'data-city_id': @default_row.city_id,
        'data-pool_type_id': @default_row.pool_type_id
      )
    end
  end
end
