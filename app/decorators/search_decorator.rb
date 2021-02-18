# frozen_string_literal: true

# = MeetingDecorator
#
class SearchDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation for methods needed by Kaminari (if the object is an AR::Relation):
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  # Returns the correct 'render' parameters depending on the type of the
  # specified collection of search results rows.
  #
  # Returns the parameters to render an empty string otherwise.
  # (null pattern used to reduce view logic)
  #
  def self.rendering_parameters(results_collection)
    if results_collection&.exists?
      case results_collection.first
      when GogglesDb::Swimmer
        { partial: 'swimmer_results', locals: { swimmers: results_collection } }

      when GogglesDb::Team
        { partial: 'team_results', locals: { teams: results_collection } }

      when GogglesDb::Meeting
        { partial: 'meeting_results', locals: { meetings: results_collection } }

      when GogglesDb::SwimmingPool
        { partial: 'swimming_pool_results', locals: { swimming_pools: results_collection } }
      end
    # Don't render anything otherwise
    else
      { plain: '' }
    end
  end
end
