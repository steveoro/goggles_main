# frozen_string_literal: true

module ComboBox
  class AutocompleteCityComponent < ViewComponent::Base
    def initialize(options = {})
      @free_text = options[:free_text] || false
      @required = options[:required] || false
      @wrapper_class = options[:wrapper_class] || 'col-auto'
      @default_row = options[:default_row] if options[:default_row].instance_of?(GogglesDb::City)
    end

    private

    def value_options
      return nil unless @default_row

      options_for_select({ @default_row.name => @default_row.id.to_i }, @default_row.id.to_i)
    end
  end
end
