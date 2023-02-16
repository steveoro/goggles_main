# frozen_string_literal: true

# = SearchController
#
# Base search response
#
class SearchController < ApplicationController
  # Returns a combined, decorated, full-text search collection of arrays
  # for any matching Swimmer, Team, Meeting or SwimmingPool.
  # Results are paginated by Kaminari.
  #
  # == Params
  # - +q+: the search query terms
  # - +raw+: set this to 1 to enable "raw mode" response (renders just the 'refreshed_content' partial, without layout)
  # - +page+: current results page; default = 1;
  #           works only if any group of results has actually more then 1 page;
  #           default per page: 5 (for each group: swimmers, teams, meetings & swimming_pools)
  #
  # == Current view structure
  # GET [XHR] --> smart.js
  #                  \
  #                   +---- search_results
  #                             \
  #                              +---- refreshed_content
  #
  # GET HTML [raw] --> refreshed_content
  #
  def smart
    unless request.xhr? || params['raw'].present?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to root_path
      return
    end

    if params['q'].blank? # Ignore empty requests
      redirect_to root_path
      return
    end

    # TODO: add manually the team of the 1st swimmer match?
    # TODO: add manually the latest 5 meetings for the of the 1st swimmer match?
    # TODO: add manually the latest 5 meetings for the team of the 1st swimmer match?
    # TODO: add manually the typical pool for the team of the 1st swimmer match?
    prepare_swimmer_search_results
    prepare_team_search_results
    prepare_meeting_search_results
    prepare_workshop_search_results
    prepare_pool_search_results
    prepare_flash_info

    respond_to do |format|
      format.html do
        render(
          partial: 'refreshed_content',
          locals: {
            swimmers: @swimmers,
            teams: @teams,
            meetings: @meetings,
            user_workshops: @user_workshops,
            swimming_pools: @swimming_pools
          }
        )
      end
      format.js
    end
  end

  private

  # Sets the @swimmers member
  def prepare_swimmer_search_results
    # @see [goggles_api]/app/api/goggles/swimmers_api.rb:132
    # (NOTE: fulltext search filters like #for_name do not need strong checking)
    like_value = "%#{params['q']}%"
    @swimmers = GogglesDb::Swimmer.for_name(params['q'])
                                  .where('complete_name LIKE ?', like_value)
                                  .page(params['page']).per(5)
  end

  # Sets the @teams member
  def prepare_team_search_results
    @teams = GogglesDb::Team.includes([:city])
                            .for_name(params['q']).by_name
                            .page(params['page']).per(5)
  end

  # Sets the @swimming_pools member
  def prepare_pool_search_results
    @swimming_pools = GogglesDb::SwimmingPool.includes([:city])
                                             .for_name(params['q']).by_name
                                             .page(params['page']).per(5)
  end

  # Sets the @meetings member
  def prepare_meeting_search_results
    @meetings = GogglesDb::Meeting.for_name(params['q'])
                                  .page(params['page']).per(5)
  end

  # Sets the @user_workshops member
  def prepare_workshop_search_results
    @user_workshops = GogglesDb::UserWorkshop.for_name(params['q'])
                                             .page(params['page']).per(5)
  end

  # Sets the flash :info with the overall result count
  def prepare_flash_info
    total_count = total_search_matches_count
    # [Steve A.] Note: *always* use flash.now instead of just flash when preparing messages
    # for a simple render without any redirection, otherwise the flash messages will
    # persist for 2 requests instead of just one.
    flash.now[:alert] = flash.now[:info] = nil

    if total_count.zero?
      flash.now[:alert] = I18n.t('search_view.no_results')
    else
      flash.now[:info] = "#{I18n.t('search_view.found_total_matches', count: total_count)} \
                      #{pagination_required? ? I18n.t('search_view.swipe_left_or_right') : ''}".html_safe
    end
  end

  # Returns the overall search matches count
  def total_search_matches_count
    @swimmers.total_count + @teams.total_count + @meetings.total_count +
      @user_workshops.total_count + @swimming_pools.total_count
  end

  # Returns +true+ if pagination will be enabled for any of the result groups; +false+ otherwise
  def pagination_required?
    @swimmers.total_pages > 1 || @teams.total_pages > 1 || @meetings.total_pages > 1 ||
      @user_workshops.total_pages > 1 || @swimming_pools.total_pages > 1
  end
end
