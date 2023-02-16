# frozen_string_literal: true

# = CalendarsGrid
#
# DataGrid used to show filtered results for any Calendar-related page.
#
class CalendarsGrid < BaseGrid
  # To set the managed teams list:
  # > MyGrid.managed_teams = @managed_teams_list
  class_attribute(:managed_teams, default: [])

  # Returns the default scope for the grid. (#assets is the filtered version of it)
  scope do
    GogglesDb::Calendar.includes(
      meeting: [
        :swimming_pools,
        { meeting_sessions: [:swimming_pool, { meeting_events: :event_type }] }
      ]
    ).distinct.order(scheduled_date: :desc)
  end

  filter(:meeting_name, :string, header: I18n.t('meetings.meeting')) do |value, scope|
    scope.where('meeting_name LIKE ?', "%#{value}%")
  end

  def row_class(_asset)
    'bg-light-cyan2'
  end
  #-- -------------------------------------------------------------------------
  #++

  column(
    :star, header: I18n.t('calendars.grid.star.title'),
           html: true, mandatory: true, order: false,
           description: I18n.t('calendars.tagging.tooltip.generic')
  )

  # Required custom column naming. See app/views/datagrid/_row.html.haml:19
  column(:calendar_date, header: I18n.t('calendars.grid.date.title'), html: true, mandatory: true, order: false) do |asset|
    if asset.meeting&.cancelled
      content_tag(:span, asset.scheduled_date) +
        content_tag(:div, I18n.t('activerecord.attributes.goggles_db/meeting.cancelled'), class: 'cancelled-row')
    else
      asset.scheduled_date
    end
  end

  # Required custom column naming: this will add another custom row after each one. See app/views/datagrid/_row.html.haml:19
  column(:calendar_name, header: I18n.t('meetings.meeting'), html: true, mandatory: true, order: false) do |asset|
    if asset.meeting
      meeting = asset.meeting
      city_name = if meeting.swimming_pools.present?
                    pool = meeting.swimming_pools.first
                    pool.city&.name
                  else
                    asset.meeting_place.to_s.split('-').last.strip
                  end
      city_name = content_tag(:b) { content_tag(:i, " - #{city_name}") }

      if meeting.cancelled
        content_tag(:del, MeetingDecorator.decorate(meeting).link_to_full_name + city_name)
      else
        content_tag(:div, MeetingDecorator.decorate(meeting).link_to_full_name + city_name)
      end
    else
      asset.meeting_name.to_s + city_name.to_s
    end
  end
end
