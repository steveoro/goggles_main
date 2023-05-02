# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  # Request Locale setter
  [nil, :it, :en, :invalid].each do |locale_sym|
    context "when setting the locale parameter as '#{locale_sym}'," do
      describe 'GET /' do
        before { get(root_path, params: { locale: locale_sym }) }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the I18n locale' do
          expected_locale = locale_sym || :it
          expected_locale = I18n.default_locale if locale_sym == :invalid
          expect(I18n.locale).to eq(expected_locale)
        end
      end
    end
  end
end
