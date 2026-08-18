# frozen_string_literal: true

#
# = MRR components module
#
#   - version:  7-0.7.19
#   - author:   Steve A.
#
module MRR
  #
  # = MRR::TableRowComponent
  #
  # Collapsible table row for MRR data display.
  #
  # Includes the rendering of relay swimmers collapsible tbody if this MRR has stored
  # any relay swimmers/laps.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - :mrr            => [required] GogglesDb::MeetingRelayResult model instance to be displayed
    # - :index          => the current MRR ordering index from its associated MPRG (if available),
    #                      spanning the event context (can substitute rank in case the rank is missing)
    # - :lap_edit       => when +true+, it will render the "lap edit" row-action button
    # - :report_mistake => when +true+, it will render the "report mistake" row-action button
    def initialize(options = {})
      @mrr = options[:mrr]
      @index = options[:index] || 0
      @lap_edit = options[:lap_edit] || false
      @report_mistake = options[:report_mistake] || false
    end

    # Skips rendering unless the member is properly set
    def render?
      return false unless @mrr.respond_to?(:id) && @mrr.id.to_i.positive?

      @mrr.is_a?(GogglesDb::MeetingRelayResult) || @mrr.is_a?(GogglesDb::MeetingRelayResultRow)
    end

    protected

    # Memoized rank value
    def rank
      @rank ||= @mrr.rank
    end

    # Memoized Meeting#id
    def meeting_id
      @meeting_id ||= @mrr&.meeting&.id
    end

    # Memoized Team association
    def team
      @team ||= @mrr.team
    end

    # Returns the link to the team results page for the current meeting,
    # using the already-loaded team instead of re-querying via the decorator.
    def team_link
      return unless team

      helpers.link_to(team.editable_name, helpers.meeting_team_results_path(id: meeting_id, team_id: team.id))
    end

    # Memoized MeetingRelaySwimmers list.
    def mrs
      @mrs ||= if @mrr.respond_to?(:meeting_relay_swimmers)
                 @mrr.meeting_relay_swimmers
               else
                 @mrr.relay_swimmers
               end
    end

    # Relay name; gives precedence to the Relay code, if present
    def relay_name
      @mrr.relay_code.presence || @mrr.team.editable_name
    end

    # Result score; gives precedence to the standard scoring system, if used
    def result_score
      @mrr.standard_points > 0.0 ? @mrr.standard_points : @mrr.meeting_points
    end
  end
end
