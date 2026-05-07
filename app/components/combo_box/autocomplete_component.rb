# frozen_string_literal: true

module ComboBox
  #
  # = ComboBox::AutocompleteComponent
  #
  class AutocompleteComponent < ViewComponent::Base
    def initialize(options = {})
      super()
      @api_url = options[:api_url].present? ? "#{base_api_url}/api/v3/#{options[:api_url]}" : nil
      @api_url2 = "#{base_api_url}/api/v3" if options[:use_2_api]
      @label = options[:label]
      @base_name = options[:base_name]
      @free_text = options[:free_text] ? 'true' : false
      @required = options[:required] || false
      @disabled = options[:disabled] || false
      @query_column = options[:query_column] || 'name'
      @bound_query_param = options[:bound_query_param]
      @wrapper_class = options[:wrapper_class] || 'col-auto'
      @values = options[:values]
      @selected_id = options[:selected_id]
      @selected_label = options[:selected_label]
    end

    def base_api_url
      GogglesDb::AppParameter.config.settings(:framework_urls).api
    end

    def placeholder_text
      @free_text ? I18n.t('lookup.placeholder_free') : I18n.t('lookup.placeholder')
    end

    protected

    def data_attributes
      {
        controller: 'autocomplete-lookup',
        'autocomplete-lookup-placeholder-value' => placeholder_text,
        'autocomplete-lookup-api-url-value' => @api_url,
        'autocomplete-lookup-field-base-name-value' => @base_name,
        'autocomplete-lookup-free-text-value' => @free_text,
        'autocomplete-lookup-query-column-value' => @query_column,
        'autocomplete-lookup-bound-query-value' => @bound_query_param,
        'autocomplete-lookup-api-url2-value' => @api_url2
      }
    end

    def hidden_id_value
      @selected_id
    end

    def hidden_label_value
      @selected_label
    end
  end
end
