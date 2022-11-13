# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController, type: :request do
  describe 'GET XHR /smart' do
    context 'without a query parameter' do
      it 'is a redirect to root_path' do
        get(search_smart_path, xhr: true)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with a query parameter matching no results' do
      before { get(search_smart_path, xhr: true, params: { q: 'NOMATCH!' }) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets a flash alert about the empty results' do
        expect(flash[:alert]).to eq(I18n.t('search_view.no_results'))
      end
    end

    context 'with a query parameter matching some results' do
      before { get(search_smart_path, xhr: true, params: { q: 'Steve' }) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets a flash info message' do
        expect(flash[:info]).to be_present
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /smart' do
    context 'without the \'raw\' parameter' do
      it 'is a redirect to root_path' do
        get(search_smart_path)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when using the \'raw\' parameter and' do
      context 'with no query parameter' do
        it 'is a redirect to root_path' do
          get(search_smart_path, params: { raw: 1 })
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with a query parameter matching no results' do
        before { get(search_smart_path, params: { raw: 1, q: 'NOMATCH!' }) }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'with a query parameter matching some results' do
        before { get(search_smart_path, params: { raw: 1, q: 'Steve' }) }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
