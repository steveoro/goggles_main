# frozen_string_literal: true

#
# = RelayLaps components module
#
#   - version:  7-0.6.30
#   - author:   Steve A.
#
module RelayLaps
  #
  # = RelayLaps::EditModalContentsComponent
  #
  # Renders the actual contents for a RelayLaps::EditModalComponent which is just the modal wrapper for
  # this ViewComponent.
  # Having 2 separate components, 1 for the contents + 1 for the wrapper, allows to render any
  # updates of the modal contents directly with 1 just component instead of iterating on all changes.
  #
  # This edit modal dialog allows relay swimmer & laps editing of the specified parent MRR / MRS.
  #
  class EditModalContentsComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>:relay_result</tt>  => [required] a valid instance of the parent <tt>GogglesDb::MeetingRelayResult</tt>;
    #                               must be already serialized (not new) since the ID is needed.
    def initialize(relay_result:)
      super
      @relay_result = relay_result
    end

    # Skips rendering unless the required parameters are set
    def render?
      @relay_result.is_a?(GogglesDb::MeetingRelayResult)
    end
    #-- -----------------------------------------------------------------------
    #++

    protected

    # Prepares the 'title' text label for the parent result, without its timing.
    # (Assumes the parent result is already serialized.)
    def result_label
      "#{@relay_result.event_type.label} #{@relay_result.gender_type.label} - #{@relay_result.category_type.short_name}"
    end

    # Memoized Team instance.
    def team
      @team ||= @relay_result.team
    end

    # Memoized list of Badge instances available for selection when adding new/missing relay fractions.
    def available_badges
      @available_badges ||= GogglesDb::Badge.joins(:swimmer)
                                            .where(team_affiliation_id: @relay_result.team_affiliation_id)
                                            .where(
                                              'badges.id NOT IN (select badge_id from meeting_relay_swimmers where meeting_relay_result_id = ?)',
                                              @relay_result.id
                                            ).distinct
                                            .order('swimmers.complete_name', 'swimmers.year_of_birth')
    end

    # Memoized EventType instance.
    def event_type
      @event_type ||= @relay_result.event_type
    end

    # Pre-computed & memoized maximum number of RelayLap instances that this type of event allows.
    # Assumes all sub-laps (RelayLaps) will have a default length of 50 meters.
    def max_relay_laps
      # Last lap is always stored in the associated MRS parent row:
      @max_relay_laps ||= (event_type.phase_length_in_meters / 50) - 1
    end

    # Pre-computed & memoized list of lengths taken from the already allocated relay fractions.
    def used_relay_fraction_lengths
      @used_relay_fraction_lengths ||= @relay_result.meeting_relay_swimmers.reload.map(&:length_in_meters)
    end

    # Pre-computed & memoized list of lengths which haven't been already set to a relay swimmer result.
    def unused_relay_fractions
      return @unused_relay_fractions if @unused_relay_fractions

      unused_phases = (1..event_type.phases).select do |phase|
        used_relay_fraction_lengths.exclude?(event_type.phase_length_in_meters * phase)
      end
      @unused_relay_fractions = unused_phases.map { |phase| event_type.phase_length_in_meters * phase }
    end

    # Pre-computed & memoized list of available relay options in a select_tag-compliant format [[<label>, <key>], ...].
    # The returned key for the select_tag will be the fraction length in meters.
    def available_relay_options
      @available_relay_options ||= unused_relay_fractions.map do |curr_length_in_meters|
        ["(#{curr_length_in_meters / event_type.phase_length_in_meters}) #{curr_length_in_meters}m", curr_length_in_meters]
      end
    end
  end
end
