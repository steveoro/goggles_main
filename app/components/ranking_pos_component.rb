# frozen_string_literal: true

#
# = RankingPosComponent
#
# Shows a unicode medal for ranks 1..3 or the +rank+ position
# otherwise.
#
class RankingPosComponent < ViewComponent::Base
  # Creates a new ViewComponent
  #
  # == Params:
  # - rank: the ranking position
  # - css: any class customization; default +nil+
  def initialize(rank:, css: nil)
    super
    @rank = rank
    @css = css
  end

  # Inline rendering
  def call
    tag.span(class: @css) do
      case @rank
      when 1
        '🥇'
      when 2
        '🥈'
      when 3
        '🥉'
      else
        @rank.to_s
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
