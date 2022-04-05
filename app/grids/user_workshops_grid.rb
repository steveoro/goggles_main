# frozen_string_literal: true

# = UserWorkshopsGrid
#
# DataGrid used to show filtered results for "My Workshops"/index page.
#
class UserWorkshopsGrid < BaseGrid
  # Returns the default scope for the grid. (#assets is the filtered version of it)
  scope do
    GogglesDb::UserWorkshop.includes(:user_results)
                           .joins(:user_results)
                           .distinct
                           .by_date(:desc)
  end

  filter(:workshop_date, :date, header: I18n.t('user_workshops.dashboard.params.workshop_date_label'),
                                input_options: { maxlength: 10, placeholder: 'YYYY-MM-DD' }) do |value, scope|
    scope.includes(season: [:season_type])
         .where('header_date >= ?', value)
  end

  filter(:workshop_name, :string, header: I18n.t('user_workshops.workshop')) do |value, scope|
    scope.for_name(value)
  end
  #-- -------------------------------------------------------------------------
  #++

  column(:workshop_date, header: I18n.t('user_workshops.header_date'), html: true, mandatory: true, order: :header_date) do |asset|
    asset.decorate.meeting_date
  end

  column(:workshop_name, header: I18n.t('user_workshops.workshop'), html: true, mandatory: true, order: :description) do |asset|
    UserWorkshopDecorator.decorate(asset).link_to_full_name
  end
end
