# frozen_string_literal: true

# = ChronoHelper
#
module ChronoHelper
  # Returns the select tag options for this entity's Select widget based either on
  # any previous choice or the default available ones.
  #
  # The choice previously made is assumed to be the ID of one of the instances from
  # the list (which is stored in a dedicated, non-encrypted cookie).
  #
  # == Params:
  # - seasons: an Array or an AR association of GogglesDb::Season instances available for selection
  #
  def season_options(seasons)
    options_from_collection_for_select(
      SeasonDecorator.decorate_collection(seasons),
      'id',
      'text_label',
      cookies[:season_id]
    )
  end

  # Returns the select tag options based either on any previous choice made or
  # nil, if no previous choice was made.
  def meeting_options
    options_for_select(
      { cookies[:meeting_label] => cookies[:meeting_id] },
      cookies[:meeting_id]
    )
  end

  # Returns the select tag options based either on any previous choice or
  # nil, if no previous choice was made.
  def workshop_options
    options_for_select(
      { cookies[:user_workshop_label] => cookies[:user_workshop_id] },
      cookies[:user_workshop_id]
    )
  end

  # Returns the select tag options for this entity's Select widget based either on
  # any previous choice or the default available ones.
  #
  # The choice previously made is assumed to be the ID of one of the instances from
  # the list (which is stored in a dedicated, non-encrypted cookie).
  #
  # == Params:
  # - pool_types: an Array or an AR association of GogglesDb::PoolType instances available for selection
  #
  def pool_type_options(pool_types)
    options_from_collection_for_select(
      pool_types,
      'id',
      'long_label',
      cookies[:pool_type_id]
    )
  end

  # Returns the select tag options for this entity's Select widget based either on
  # any previous choice or the default available ones.
  #
  # The choice previously made is assumed to be the ID of one of the instances from
  # the list (which is stored in a dedicated, non-encrypted cookie).
  #
  # == Params:
  # - event_types: an Array or an AR association of GogglesDb::EventType instances available for selection
  #
  def event_type_options(event_types)
    options_from_collection_for_select(
      event_types,
      'id',
      'long_label',
      cookies[:event_type_id]
    )
  end

  # Returns the select tag options for this entity's Select widget based either on
  # any previous choice or the default available ones.
  #
  # The choice previously made is assumed to be the ID of one of the instances from
  # the list (which is stored in a dedicated, non-encrypted cookie).
  #
  # == Params:
  # - category_types: an Array or an AR association of GogglesDb::CategoryType instances available for selection
  #
  def category_type_options(category_types)
    options_from_collection_for_select(
      category_types,
      'id',
      'short_name',
      cookies[:category_type_id]
    )
  end

  # Returns the select tag options for this entity's Select widget based either on
  # any previous choice or the default available ones.
  #
  # The choice previously made depends from both the last chosen Team or the last chosen
  # swimmer.
  # If there's a previously chosen Team, that will take precedence. If there isn't one but
  # there's a previously chosen Swimmer, the associated teams for the chosen swimmer will
  # cover for the list of selectable teams and the first one in list will be the default choice.
  #
  # == Params:
  # - last_chosen_team: a previously chosen GogglesDb::Team instance, when available
  # - last_chosen_swimmer: a previously chosen GogglesDb::Swimmer instance, when available
  #
  def team_options(last_chosen_team, last_chosen_swimmer)
    if last_chosen_team
      return options_for_select(
        { last_chosen_team.name => last_chosen_team.id.to_i },
        last_chosen_team.id.to_i
      )
    end
    return unless last_chosen_swimmer

    decorated_swimmer = SwimmerDecorator.decorate(last_chosen_swimmer)
    options_from_collection_for_select(
      decorated_swimmer.associated_teams,
      'id',
      'editable_name',
      decorated_swimmer.associated_teams.first&.id.to_i
    )
  end
end
