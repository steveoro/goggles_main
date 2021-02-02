# frozen_string_literal: true

Rails.application.routes.draw do
  mount GogglesDb::Engine => '/'
  root to: 'home#index'

  get 'home/index'
  get 'home/about'
end
