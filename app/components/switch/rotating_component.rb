# frozen_string_literal: true

#
# = Switch components module
#
#   - version:  7-0.6.00
#   - author:   Steve A.
#
module Switch
  #
  # = Switch::RotatingComponent
  #
  # Collapse toggle switch.
  # Specify the collapsed body DOM ID as target for the component.
  #
  class RotatingComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>target_id</tt>: a collapsed body DOM ID as target for the component; the component will toggle
    #   the collapse CSS class from the target, if available.
    #
    # - <tt>option_classes</tt>: additional CSS class names for customization.
    # - <tt>remote_url</tt>: optional URL to fetch by Turbo Stream before toggling locally.
    # - <tt>expanded</tt>: optional initial expanded state (default: +false+).
    # - <tt>title</tt>: optional trigger title attribute.
    # - <tt>aria_label</tt>: optional trigger aria-label.
    #
    def initialize(options = {})
      @target_id = options[:target_id]
      @option_classes = options[:option_classes] || ''
      @remote_url = options[:remote_url]
      @expanded = options[:expanded] || false
      @title = options[:title]
      @aria_label = options[:aria_label]
    end

    def render?
      @target_id.present?
    end

    protected

    def remote?
      @remote_url.present?
    end

    def trigger_id
      "toggle-#{@target_id}"
    end

    def trigger_classes
      [
        'rotating-toggle',
        @expanded ? 'is-expanded' : 'is-collapsed',
        @option_classes
      ].compact_blank.join(' ')
    end

    def trigger_data
      {
        controller: remote? ? 'rotating-switch loading' : 'rotating-switch',
        action: remote? ? 'click->rotating-switch#toggle click->loading#show' : 'click->rotating-switch#toggle',
        'rotating-switch-target-id-value': @target_id,
        'rotating-switch-remote-value': remote?
      }.tap do |data|
        data[:turbo_stream] = true if remote?
      end
    end

    def trigger_aria_label
      @aria_label.presence || "switch for #{@target_id}"
    end
  end
end
