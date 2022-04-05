# frozen_string_literal: true

# = MeetingHelper
#
module MeetingHelper
  # Prepares a string <tt>link_to(meeting_show_path(id))</tt> given the parameters when only the individual
  # field values are known (avoids a query).
  #
  # Typical use case: options returned from the SwimmerStat or TeamStat models.
  #
  # Returns +nil+ in case of any missing options.
  #
  # NOTE: if a +Meeting+ instance is available, just use its decorator's #link_to_full_name method instead
  #       and don't use this helper.
  #
  # == Required options:
  # - 'meeting_id' => Meeting ID
  # - 'federation_code' => Federation code for the Championship Season
  # - 'meeting_date' => Meeting's scheduled date or header date
  # - 'meeting_description' => Meeting full description
  #
  # rubocop:disable Rails/OutputSafety
  def meeting_show_link(options = {})
    return unless options.present? && %w[meeting_id federation_code meeting_date meeting_description].all? { |key| options[key].present? }

    link_to(
      "(#{options['federation_code']} #{options['meeting_date']}) #{options['meeting_description']}".html_safe,
      meeting_show_path(id: options['meeting_id'])
    )
  end
  # rubocop:enable Rails/OutputSafety
end
