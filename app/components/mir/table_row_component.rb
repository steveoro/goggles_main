# frozen_string_literal: true

#
# = MIR components module
#
#   - version:  7-0.7.08
#   - author:   Steve A.
#
module MIR
  #
  # = MIR::TableRowComponent
  #
  # => Suitable for *any* AbstractResult <=
  #
  # Collapsible table row for MIR data display.
  #
  # Includes the rendering of laps collapsible tbody if this MIR has stored laps.
  #
  class TableRowComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Supported options:
    # All optional except +mir+:
    #
    # - :mir            => [required] the GogglesDb::MeetingIndividualResult model instance to be displayed
    # - :index          => the current MIR ordering index from its associated MPRG (if available),
    #                      spanning the event context (can substitute rank in case the rank is missing)
    # - :lap_edit       => when +true+, it will render the "lap edit" row-action button
    # - :report_mistake => when +true+, it will render the "report mistake" row-action button
    # - :show_category  => when +true+, it will render the category name after the year of birth
    # - :show_team => when +true+ (default), it will render the link to the team results page associated with this MIR row
    #
    def initialize(options = {}) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      super
      @mir = options[:mir]
      @index = options[:index] || 0
      @lap_edit = options[:lap_edit] || false
      @report_mistake = options[:report_mistake] || false
      @show_category = options[:show_category] || false
      @show_team = options[:show_team] || options[:show_team].nil? # (default true)
      @season_type = @mir.season.season_type if @mir.respond_to?(:season)
      # [Steve, 20240410] Moving laps relation (already sorted) to memory to prevent further queries:
      @laps = @mir.laps.to_a.sort_by(&:length_in_meters) if @mir.respond_to?(:laps)
    end

    # Skips rendering unless the member is properly set
    def render?
      @mir.class.ancestors.include?(GogglesDb::AbstractResult) && @mir.swimmer_id.to_i.present?
    end

    protected

    attr_reader :season_type, :laps

    # Memoized Meeting#id
    def meeting_id
      return @meeting_id if @meeting_id.present?

      @meeting_id = @mir&.parent_meeting&.id
    end

    # Memoized associated CategoryType code
    def category_code
      return @category_code if @category_code.present?

      @category_code = @mir&.category_type&.code
    end

    # Memoized rank value
    def rank
      return @rank if @rank.present?

      @rank = @mir.rank
    end

    # Memoized Swimmer association
    def swimmer
      return @swimmer if @swimmer.present?
      return unless @mir.respond_to?(:swimmer_id) && @mir.swimmer_id.to_i.positive?

      @swimmer = @mir.swimmer
    end

    # Memoized Team association
    def team
      return @team if @team.present?
      return unless @mir.respond_to?(:team_id) && @mir.team_id.to_i.positive?

      @team = @mir.team
    end

    # Memoized SwimmingPool association
    def swimming_pool
      return @swimming_pool if @swimming_pool.present?
      return unless @mir.respond_to?(:swimming_pool_id) && @mir.swimming_pool_id.to_i.positive?

      @swimming_pool = @mir.swimming_pool
    end

    # Memoized lap presence
    def includes_laps?
      return @includes_laps if @includes_laps.present?

      @includes_laps = laps&.present?
    end

    # Result score. Gives precedence to the standard FIN Championship scoring system, if set or used.
    # Fallback: CSI Championship scoring system when standard or meeting points are not set and
    # the season type is right.
    def result_score
      result_score = @mir.standard_points.positive? ? @mir.standard_points : @mir.meeting_points
      return result_score unless result_score.zero?

      # Do not compute CSI score unless the season type is correct:
      compute_csi_score if season_type == GogglesDb::SeasonType.mas_csi
    end

    # Computes points based on ranking, according to the CSI Championship rules.
    def compute_csi_score
      score = 100 - ((rank - 1) * 5)
      score.positive? ? score : 0
    end
  end
end
