# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  devise_for :users, class_name: 'GogglesDb::User',
                     controllers: {
                       omniauth_callbacks: 'users/omniauth_callbacks',
                       registrations: 'users/registrations',
                       sessions: 'users/sessions'
                     }
  root to: 'home#index'

  # Mounting and usage of the Core Engine:
  mount GogglesDb::Engine => '/'
  # Job UI:
  authenticated :user, ->(user) { GogglesDb::GrantChecker.admin?(user) } do
    mount Delayed::Web::Engine, at: '/jobs'
  end

  post 'api_sessions/jwt', format: :json
  get 'users/google_oauth/continue'

  get 'calendars/current'
  get 'calendars/starred'
  get 'calendars/starred_map'

  get 'home/index'
  get 'home/about'
  get 'home/contact_us'
  post 'home/contact_us'
  get 'home/dashboard'

  get 'chrono', to: 'chrono#index'
  get 'chrono/index'
  get 'chrono/download/:id', to: 'chrono#download', as: 'chrono_download'
  get 'chrono/new'
  post 'chrono/rec'
  post 'chrono/commit'
  delete 'chrono/delete/:id', to: 'chrono#delete', as: 'chrono_delete'

  get 'issues/faq_index' # FAQ-like landing page
  get 'issues/my_reports' # actual report index for the current user
  get 'issues/new_type0'
  get 'issues/new_type1b'
  get 'issues/new_type1b1'
  get 'issues/new_type2b1'
  post 'issues/create_type0'
  post 'issues/create_type1a'
  post 'issues/create_type1b'
  post 'issues/create_type1b1'
  post 'issues/create_type2b1'
  post 'issues/create_type3b'
  post 'issues/create_type3c'
  post 'issues/create_type4'

  post 'laps/edit_modal' # XHR only
  resources :laps, only: %i[create update destroy] # XHR only

  put 'lookup/matching_swimmers'

  get 'maintenance', to: 'maintenance#index'
  get 'search/smart'

  get 'meetings',                 to: 'meetings#index',       as: 'meetings'
  get 'meetings/show/:id',        to: 'meetings#show',        as: 'meeting_show'
  get 'meetings/for_swimmer/:id', to: 'meetings#for_swimmer', as: 'meetings_for_swimmer'
  get 'meetings/for_team/:id',    to: 'meetings#for_team',    as: 'meetings_for_team'

  get 'swimming_pools/show/:id', to: 'swimming_pools#show', as: 'swimming_pool_show'

  get 'swimmers/show/:id',          to: 'swimmers#show',          as: 'swimmer_show'
  get 'swimmers/history_recap/:id', to: 'swimmers#history_recap', as: 'swimmer_history_recap'
  get 'swimmers/:id/history/:event_type_id', to: 'swimmers#history', as: 'swimmer_history'

  post 'taggings/by_user/:meeting_id', to: 'taggings#by_user', as: 'taggings_by_user'
  post 'taggings/by_team', to: 'taggings#by_team', as: 'taggings_by_team' # (No required parameters by design)

  get 'teams/show/:id',             to: 'teams#show',             as: 'team_show'
  get 'teams/current_swimmers/:id', to: 'teams#current_swimmers', as: 'team_current_swimmers'

  get 'user_workshops',                 to: 'user_workshops#index',       as: 'user_workshops'
  get 'user_workshops/show/:id',        to: 'user_workshops#show',        as: 'user_workshop_show'
  get 'user_workshops/for_swimmer/:id', to: 'user_workshops#for_swimmer', as: 'user_workshops_for_swimmer'
  get 'user_workshops/for_team/:id',    to: 'user_workshops#for_team',    as: 'user_workshops_for_team'

  get 'tools/fin_score'
  # TODO: move the following to a dedicated API endpoint:
  get 'tools/compute_fin_score', format: :json

  # Catch-all redirect in case of 404s
  get '*path', to: 'application#redirect_missing'
end
# rubocop:enable Metrics/BlockLength
