# frozen_string_literal: true

# = MeetingsGrid
#
# DataGrid used to show filtered results for "My Meetings"/index page.
#
class MeetingsGrid < BaseGrid
  # Returns the default scope for the grid. (#assets is the filtered version of it)
  scope do
    GogglesDb::Meeting.includes(:meeting_sessions)
                      .joins(:meeting_sessions)
                      .by_date(:desc)
                      .distinct
  end

  filter(:meeting_date, :date, header: I18n.t('meetings.dashboard.params.meeting_date_label'),
                               input_options: { maxlength: 10, placeholder: 'YYYY-MM-DD' }) do |value, scope|
    scope.includes(:meeting_sessions)
         .joins(:meeting_sessions)
         .where('header_date >= ? OR meeting_sessions.scheduled_date >= ?', value, value)
  end

  filter(:meeting_name, :string, header: I18n.t('meetings.meeting')) do |value, scope|
    scope.for_name(value)
  end
  #-- -------------------------------------------------------------------------
  #++

  column(:meeting_date, header: I18n.t('meetings.header_date'), html: true, mandatory: true, order: :header_date) do |asset|
    asset.decorate.meeting_date
  end

  column(:meeting_name, header: I18n.t('meetings.meeting'), html: true, mandatory: true, order: :description) do |asset|
    MeetingDecorator.decorate(asset).link_to_full_name
  end
end
