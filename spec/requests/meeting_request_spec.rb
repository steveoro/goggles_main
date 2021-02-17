# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Meetings', type: :request do
  describe 'GET /show' do
    it 'returns http success' do
      get '/meeting/show'
      expect(response).to have_http_status(:success)
    end
  end
end
