# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/home/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /about_us' do
    it 'returns http success' do
      get '/home/about_us'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /about_this' do
    it 'returns http success' do
      get '/home/about_this'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /contact_us' do
    it 'returns http success' do
      get '/home/contact_us'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /privacy_policy' do
    it 'returns http success' do
      get '/home/privacy_policy'
      expect(response).to have_http_status(:success)
    end
  end
end
