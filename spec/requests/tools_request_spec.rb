# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools', type: :request do
  describe 'GET XHR /fin_score' do
    it 'returns http success' do
      get('/tools/fin_score', xhr: true)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /fin_score' do
    it 'returns http success' do
      get '/tools/fin_score'
      expect(response).to have_http_status(:success)
    end
  end
end
