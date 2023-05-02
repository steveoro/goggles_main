# frozen_string_literal: true

#
# = MIR components module
#
#   - version:  7-0.5.02
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
    # - :index          => the current MIR index, spanning the event context (can substitute rank when rank is missing)
    # - :lap_edit       => when +true+, it will render the "lap edit" row-action button
    # - :report_mistake => when +true+, it will render the "report mistake" row-action button
    # - :show_category  => when +true+, it will render the category name after the year of birth
    # - :show_team => when +true+ (default), it will render the link to the team results page associated with this MIR row
    #
    def initialize(options = {})
      super
      @mir = options[:mir]
      @index = options[:index] || 0
      @lap_edit = options[:lap_edit] || false
      @report_mistake = options[:report_mistake] || false
      @show_category = options[:show_category] || false
      @show_team = options[:show_team] || options[:show_team].nil? # (default true)
    end

    # Skips rendering unless the member is properly set
    def render?
      @mir.class.ancestors.include?(GogglesDb::AbstractResult) && @mir.swimmer_id.to_i.present?
    end

    protected

    # Memoized Meeting#id
    def meeting_id
      @meeting_id ||= @mir&.parent_meeting&.id
    end

    # Memoized associated CategoryType code
    def category_code
      @category_code ||= @mir&.category_type&.code
    end

    # Memoized rank value
    def rank
      @rank ||= @mir.rank.to_i.positive? ? @mir.rank.to_i : @index + 1
    end

    # Memoized Swimmer association
    def swimmer
      return unless @mir.respond_to?(:swimmer_id) && @mir.swimmer_id.to_i.positive?

      @swimmer ||= GogglesDb::Swimmer.find_by(id: @mir.swimmer_id)
    end

    # Memoized Team association
    def team
      return unless @mir.respond_to?(:team_id) && @mir.team_id.to_i.positive?

      @team ||= GogglesDb::Team.find_by(id: @mir.team_id)
    end

    # Memoized SwimmingPool association
    def swimming_pool
      return unless @mir.respond_to?(:swimming_pool_id) && @mir.swimming_pool_id.to_i.positive?

      @swimming_pool ||= GogglesDb::SwimmingPool.find_by(id: @mir.swimming_pool_id)
    end

    # Memoized & generalized lap association
    def laps
      # [Steve, 20230321] Although we have already defined an alias for user_laps
      # in UserResults (as the #laps method), we cannot define two conflicting has_many clauses
      # referring to the same destination model. Thus comes the quick hack below:
      lap_includes_sym = @mir.is_a?(GogglesDb::UserResult) ? :user_laps : :laps
      @laps ||= @mir.class.includes(lap_includes_sym).find_by(id: @mir.id).laps
    end

    # Memoized lap presence
    def includes_laps?
      @includes_laps ||= laps&.count&.positive?
    end

    # Memoized season type
    def season_type
      @season_type ||= @mir.season_type
    end

    # Result score. Gives precedence to the standard FIN Championship scoring system, if set or used.
    # Fallback: CSI Championship scoring system when standard or meeting points are not set.
    def result_score
      result_score = @mir.standard_points.positive? ? @mir.standard_points : @mir.meeting_points
      return result_score unless result_score.zero?

      compute_csi_score
    end

    # Computes points based on ranking, according to the CSI Championship rules.
    def compute_csi_score
      score = 100 - ((rank - 1) * 5)
      score.positive? ? score : 0
    end
  end
end
