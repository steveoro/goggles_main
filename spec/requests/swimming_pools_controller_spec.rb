# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_request_examples'

RSpec.describe SwimmingPoolsController do
  describe 'GET /show/:id' do
    context 'with a valid row id' do
      let(:swimming_pool_id) { GogglesDb::SwimmingPool.first(100).pluck(:id).sample }

      it 'returns http success' do
        get(swimming_pool_show_path(swimming_pool_id))
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid row id' do
      before { get(swimming_pool_show_path(-1)) }

      it_behaves_like('invalid row id GET request')
    end
  end
end
