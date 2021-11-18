# frozen_string_literal: true

# = SeasonDecorator
#
class SeasonDecorator < Draper::Decorator
  delegate_all

  # Returns the default text label describing this object.
  def text_label
    object.decorate.display_label
  end
end
