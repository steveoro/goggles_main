# frozen_string_literal: true

#
# = FlashAlertComponent
#
# Render a dismissable flash message alert
#
class FlashAlertComponent < ViewComponent::Base
  # Supported flash items
  SUPPORTED_SYMS = %i[error warning alert info notice].freeze

  # Creates a new ViewComponent.
  #
  # == Params:
  # - symbol: the flash symbol that will set the alert theme (:info, :notice, :alert, :warning, :error)
  # - title: an additional text title (can be +nil+)
  # - body: the actual text body of the message
  def initialize(symbol:, body:, title: nil)
    super
    @symbol = symbol
    @title = title
    @body = body
  end

  # Skips rendering unless both :symbol & :body are valid
  def render?
    SUPPORTED_SYMS.include?(@symbol) && @body.to_s.present?
  end

  protected

  # Returns the background CSS depending on @symbol value
  def alert_background_class
    case @symbol
    when :error
      'alert-danger'
    when :warning, :alert
      'alert-warning'
    when :info
      'alert-info'
    when :notice
      'alert-secondary'
    end
  end

  # Returns the background CSS depending on @symbol value
  def alert_title_class
    case @symbol
    when :error
      'fa-exclamation-triangle text-danger'
    when :warning
      'fa-exclamation-circle text-warning'
    when :alert
      'fa-info-circle text-secondary'
    when :info, :notice
      'fa-info-circle text-success'
    end
  end
end
