# frozen_string_literal: true

# = HistoryGrid
#
# DataGrid showing filtered Meeting results for the Swimmer "History" detail page.
#
# The base scope must be always filtered by:
# - the current Swimmer ID
# - the current EventType ID
# (both enforced by routes)
#
class HistoryGrid < BaseGrid
  # Returns the default scope for the grid. (#assets is the filtered version of it)
  scope do
    GogglesDb::MeetingIndividualResult.includes(
      :meeting, :event_type, :pool_type,
      :meeting_event, meeting_program: [:meeting, :pool_type, { meeting_event: [:event_type] }]
    ).joins(:meeting, :pool_type).by_date(:desc)
  end

  filter(:pool_type, :enum, header: I18n.t('meetings.dashboard.pool_type_short'),
                            select: proc {
                                      [
                                        [GogglesDb::PoolType.mt_25.label, GogglesDb::PoolType::MT_25_ID],
                                        [GogglesDb::PoolType.mt_50.label, GogglesDb::PoolType::MT_50_ID]
                                      ]
                                    }) do |value, scope|
    scope.where('pool_types.id': value)
  end

  filter(:meeting_date, :date, header: I18n.t('swimmers.history.params.meeting_date_label'),
                               input_options: { maxlength: 10, placeholder: 'YYYY-MM-DD' }) do |value, scope|
    scope.where('meetings.header_date >= ?', value)
  end

  filter(:meeting_name, :string, header: I18n.t('meetings.meeting')) do |value, scope|
    scope.where('MATCH(meetings.description, meetings.code) AGAINST(?)', value)
  end

  # Customizes row background color
  def row_class(row)
    'bg-light-cyan2' if row&.pool_type&.id == GogglesDb::PoolType::MT_25_ID
  end
  #-- -------------------------------------------------------------------------
  #++

  column(:meeting_date, header: I18n.t('meetings.header_date'), html: true, mandatory: true,
                        order: 'meetings.header_date') do |asset|
    asset.meeting.decorate.meeting_date
  end

  column(:meeting_name, header: I18n.t('meetings.meeting'), html: true, mandatory: true,
                        order: 'meetings.description') do |asset|
    MeetingDecorator.decorate(asset.meeting).link_to_full_name
  end

  column(:pool_type, header: I18n.t('meetings.dashboard.pool_type_short'), html: true, mandatory: true,
                     order: 'pool_types.code') do |asset|
    asset.pool_type.length_in_meters
  end

  column(:timing, header: '⏱', html: true, mandatory: true,
                  order: 'minutes * 6000 + seconds * 100 + hundredths') do |asset|
    timing = asset.to_timing
    timing.to_hundredths.zero? ? '-' : timing.to_s
  end

  column(:rank, header: '🏅', html: true, mandatory: true,
                order: 'rank is not null desc, rank',
                order_desc: 'rank is not null desc, rank desc') do |asset|
    if asset.rank.to_i.positive?
      render(RankingPosComponent.new(rank: asset.rank.to_i))
    else
      '-'
    end
  end
end
