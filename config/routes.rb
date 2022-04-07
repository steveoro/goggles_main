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

  # Mounting and usage of the Engine:
  mount GogglesDb::Engine => '/'

  post 'api_sessions/jwt', format: :json
  get 'users/google_oauth/continue'

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

  get 'teams/show/:id',             to: 'teams#show',             as: 'team_show'
  get 'teams/current_swimmers/:id', to: 'teams#current_swimmers', as: 'team_current_swimmers'

  get 'user_workshops',                 to: 'user_workshops#index',       as: 'user_workshops'
  get 'user_workshops/show/:id',        to: 'user_workshops#show',        as: 'user_workshop_show'
  get 'user_workshops/for_swimmer/:id', to: 'user_workshops#for_swimmer', as: 'user_workshops_for_swimmer'
  get 'user_workshops/for_team/:id',    to: 'user_workshops#for_team',    as: 'user_workshops_for_team'

  get 'tools/fin_score'
  # TODO: move the following to a dedicated API endpoint:
  get 'tools/compute_fin_score', format: :json
end
# rubocop:enable Metrics/BlockLength
