# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, class_name: 'GogglesDb::User',
                     controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # Mounting and usage of the Engine:
  mount GogglesDb::Engine => '/'
  root to: 'home#index', locale: /it|en/

  get 'home/index'
  get 'home/about_us'
  get 'home/about_this'
  get 'home/contact_us'
  get 'home/privacy_policy'

  get 'maintenance', to: 'maintenance#index'
  get 'search/smart'

  get 'meeting/show'
  get 'swimming_pool/show'
  get 'swimmer/show'
  get 'team/show'

  get 'tools/fin_score'
end
