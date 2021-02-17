# frozen_string_literal: true

# = SwimmerDecorator
#
class SwimmerDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  # Returns the swimmer age (as a numeric value) for a given +date+.
  #
  # == Params
  # - date: the date for which the age must be computed; default: +today+.
  #
  def swimmer_age(date = Date.today)
    date.year - year_of_birth
  end

  # Returns the link to /swimmer/show using the complete name as link label.
  #
  def link_to_full_name
    h.link_to(complete_name, h.swimmer_show_path(id: object.id))
    # [Steve, 20210208] Adding a tooltip here doesn't give a good UX for the moment:
    # data: { toggle: 'tooltip', title: I18n.t('swimmers.go_to_dashboard') }
  end

  # Returns the array list of all the distinct team IDs associated
  # to the object row through the available Badges.
  #
  # Returns an empty array when nothing is found.
  #
  def associated_team_ids
    GogglesDb::Badge.for_swimmer(object).select(:team_id).distinct.map(&:team_id)
  end

  # Returns a comma-separated string text mapping all the distinct team
  # names associated with the object row.
  #
  # Returns an empty string if no teams are available through the
  # Swimmer's badges.
  #
  # == Params
  # - max_length: truncate length for names; default: 20 (characters)
  #
  def link_to_teams(max_length = 20)
    links = GogglesDb::Team.where(id: associated_team_ids).map do |team|
      short_name = h.truncate(team.editable_name, length: max_length, separator: ' ')
      h.tag.li(h.link_to(short_name, h.team_show_path(id: team.id)))
      # [Steve, 20210208] Adding a tooltip here doesn't give a good UX for the moment:
      # data: { toggle: 'tooltip', title: I18n.t('teams.go_to_dashboard') }
    end
    h.tag.ul(
      links.join("\r\n").html_safe, class: 'p-0 ml-3'
    ).html_safe
    # TODO: when badge association will be set:
    # teams ? teams.collect(&:name).uniq.join(', ') : ''
  end

  # Returns the last category type code found given for this swimmer
  # (assuming at least 1 associated badge exists)
  def last_category_code
    GogglesDb::Badge.for_swimmer(object).by_season
                    .includes(:category_type)
                    .last&.category_type&.code
  end

  # Returns the computed current FIN category code given regardless the existance of
  # a badge for the object swimmer.
  def current_fin_category_code
    age = swimmer_age
    # Retrieve the last available FIN Season that includes a CategoryType which has
    # the swimmer age in range:
    last_fin_season = GogglesDb::Season.joins(:category_types)
                                       .for_season_type(GogglesDb::SeasonType.mas_fin)
                                       .where('(age_end >= ?) AND (age_begin <= ?)', age, age)
                                       .last
    return nil unless last_fin_season

    # Use the "full" FIN season to get the actual (first) available type code for the category:
    GogglesDb::CategoryType.for_season(last_fin_season)
                           .where('(age_end >= ?) AND (age_begin <= ?)', age, age)
                           .first
                           &.code
  end
end
