# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rack Attack throttling' do
  around do |example|
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.reset!
    example.run
  ensure
    Rack::Attack.enabled = false
    Rack::Attack.cache.store = Rails.cache
  end

  before do
    allow(GogglesDb::AppParameter).to receive_messages(max_bot_req: 3, max_req_per_minute: 5)
  end

  let(:bot_headers) { { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; GPTBot/1.0)' } }
  let(:browser_headers) { { 'HTTP_USER_AGENT' => 'Mozilla/5.0' } }

  it 'throttles bot requests after the daily bot limit' do
    3.times do
      get(root_path, headers: bot_headers)
      expect(response.status).to be_in([200, 302])
    end

    get(root_path, headers: bot_headers)

    expect(response).to have_http_status(:too_many_requests)
    expect(response.headers['Retry-After']).to be_present
  end

  it 'throttles browser requests after the per-minute limit' do
    5.times do
      get(root_path, headers: browser_headers)
      expect(response.status).to be_in([200, 302])
    end

    get(root_path, headers: browser_headers)

    expect(response).to have_http_status(:too_many_requests)
  end

  it 'exempts the health endpoint and does not track its requests' do
    expect do
      10.times do
        get('/up', headers: bot_headers)
        expect(response).to have_http_status(:success)
      end
    end.not_to change(GogglesDb::APIDailyUseAgent, :count)
  end

  it 'does not throttle when disabled' do
    Rack::Attack.enabled = false

    10.times do
      get(root_path, headers: bot_headers)
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end
end
