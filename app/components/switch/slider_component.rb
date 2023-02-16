# frozen_string_literal: true

#
# = Switch components module
#
module Switch
  #
  # = Switch::SliderComponent
  #
  #   - version:  7-0.3.40
  #   - author:   Steve A.
  #
  # Boolean switch that can acts as a collapse toggle or as a form boolean switch, or as both.
  # Does *not* work for multiple radio-like select checkboxes.
  # (Prefer default Bootstrap check boxes styling for that instead of this component.)
  #
  # === Supports:
  # - rounded/squared borders: use +'round'+ for rounded (default: squared)
  # - green/red background: use +'red'+ to override green default
  # - namespaced fields inside forms (i.e.: input name: 'namespace[field_name]' => form ID 'namespace_field_name')
  #
  # === Usage as a collapse toggle:
  # Use <tt>target_id</tt> (DOM) with default options.
  #
  # === Usage for "boolean" form values:
  # Use <tt>field_id</tt> (Form) with default options.
  #
  class SliderComponent < ViewComponent::Base
    # Creates a new ViewComponent.
    #
    # == Params
    # - <tt>field_name</tt>: hidden field name, used for posting form values; defaults to +nil+ to skip rendering of
    #   the hidden field.
    #
    # - <tt>target_id</tt>: a collapsed body DOM ID as target for the component; the component will toggle
    #   the collapse CSS class from the target, if available.
    #
    # - <tt>option_classes</tt>: CSS class names for customization ('round', 'red', both or anything else)
    #
    # Either <tt>target_id</tt> or <tt>field_name</tt> must be set for the component to be
    # rendered.
    #
    def initialize(field_name: nil, target_id: nil, option_classes: '')
      super
      @target_id = target_id
      @option_classes = option_classes
      @field_name = field_name
    end

    # Skips rendering unless the required parameters are set
    def render?
      @target_id.present? || @field_name.present?
    end

    protected

    # Returns the base DOM ID for the hidden field changing any form-only namespaces to snake_case
    # (i.e. "base_namespace[field_name]" => "base_namespace_field_name").
    def base_field_id
      @base_field_id ||= @field_name&.gsub('[', '_')&.gsub(']', '')
    end
  end
end
