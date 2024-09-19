# frozen_string_literal: true

#
# = RankingPosComponent
#
# Shows a unicode medal for ranks 1..3 or the +rank+ position
# otherwise. Adds also a tooltip with any +dsq_notes+ when a text value is provided.
#
class RankingPosComponent < ViewComponent::Base
  # Creates a new ViewComponent
  #
  # == Params:
  # - rank: the ranking position
  # - dsq_notes: any text note to be displayed as a tooltip, typically for DSQ results only; default: +nil+
  # - css: any class customization; default +nil+
  def initialize(rank:, dsq_notes: nil, css: nil)
    super
    @rank = rank
    @dsq_notes = dsq_notes
    @css = css
  end

  # Inline rendering
  def call
    tag.span(class: @css, data: 'tooltip', title: @dsq_notes) do
      case @rank
      when 1
        '🥇'
      when 2
        '🥈'
      when 3
        '🥉'
      else
        @rank.to_i.zero? ? '🚫' : @rank.to_s
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
