# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maintenances', type: :request do
  describe 'GET /maintenance' do
    context 'if the mainenance mode if off' do
      before(:each) { GogglesDb::AppParameter.maintenance = false }

      it 'redirects to root_path' do
        get(maintenance_path)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'if the mainenance mode if on' do
      before(:each) { GogglesDb::AppParameter.maintenance = true }

      it 'returns http success' do
        get(maintenance_path)
        expect(response).to have_http_status(:success)
      end

      context 'any other request' do
        it 'redirects to maintenance_path' do
          # Just a few sample paths:
          get([root_path, home_contact_us_path, home_about_us_path, search_smart_path].sample)
          expect(response).to redirect_to(maintenance_path)
        end
      end
    end
  end
end
