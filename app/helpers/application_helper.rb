# frozen_string_literal: true

# = ApplicationHelper
#
# Common parent helper
module ApplicationHelper
  # Convert grid filters to visible labels
  #
  # == Params:
  # - main_namespace: the master name-space for the localization of the grid parameters
  #                   (e.g. 'meetings.dashboard' or 'swimmers.history', etc.; the parent namespace
  #                   before the 'params' part)
  # - grid_filter_params: the grid filter params hash
  #
  # == Returns:
  # A string with the translated labels separated by commas.
  #
  def grid_filter_to_labels(main_namespace, grid_filter_params)
    return '' unless grid_filter_params.respond_to?(:to_hash)

    grid_filter_params.reject { |key, value| value.blank? || key == 'order' || key == 'descending' }
                      .to_hash
                      .map { |key, value| I18n.t("#{main_namespace}.params.#{key}", value: value) }
                      .join(', ')
  end
end
