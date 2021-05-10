# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Chronos', type: :request do
  describe 'GET /chrono/index' do
    it 'returns http success' do
      get(chrono_index_path)
      expect(response).to have_http_status(:success)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /chrono/new' do
    it 'returns http success' do
      get(chrono_new_path)
      expect(response).to have_http_status(:success)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /chrono/rec' do
    it 'returns http success' do
      post(chrono_rec_path)
      # TODO: test failing w/ flash error
      # TODO: test success w/ flash notice
      expect(response).to redirect_to(chrono_index_path)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
