# frozen_string_literal: true

# = SeasonDecorator
#
class SeasonDecorator < Draper::Decorator
  delegate_all

  # Generic Season helper.
  # Returns the last Season given its specified type; +nil+ otherwise.
  #
  # == Params
  # - season_type_id: the filtering SeasonType id
  #
  # == Note
  # The returned last Season is *not* decorated
  #
  # @see GogglesDb::Season, GogglesDb::SeasonType
  def last_season_by_type(season_type_id)
    GogglesDb::Season.joins(:season_type).includes(:season_type)
                     .where('season_types.id': season_type_id)
                     .by_begin_date
                     .last
  end
end
