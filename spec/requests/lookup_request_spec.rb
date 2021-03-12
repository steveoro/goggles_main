# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lookups', type: :request do
  describe 'PUT /matching_swimmers' do
    context 'for an unlogged user' do
      it 'is a redirect to the login path' do
        put(lookup_matching_swimmers_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a logged-in user' do
      before(:each) do
        user = GogglesDb::User.first(50).sample
        sign_in(user)
      end

      context 'without some of the required parameters,' do
        [
          { last_name: 'Smith', year_of_birth: '' },
          { first_name: 'Paul', year_of_birth: '' },
          { first_name: '', last_name: 'Smith' }
        ].each do |sub_params|
          before(:each) { put(lookup_matching_swimmers_path, params: { user: sub_params }) }

          it 'is successful' do
            expect(response).to be_successful
          end
          it 'responds with an empty body' do
            expect(response.body).to be_empty
          end
        end
      end

      context 'with valid parameters,' do
        before(:each) do
          put(
            lookup_matching_swimmers_path,
            params: { user: { first_name: '', last_name: 'Smith', year_of_birth: '' } }
          )
        end

        it 'is successful' do
          expect(response).to be_successful
        end
        it 'returns the matching swimmers as select options' do
          puts "\r\n#{response.body}"
          matches = GogglesDb::User.new(last_name: 'Smith').matching_swimmers
          expect(matches).to be_positive
          matches.each do |swimmer|
            expect(response.body).to include(ERB::Util.html_escape(swimmer.complete_name))
            expect(response.body).to include(swimmer.year_of_birth)
          end
        end
      end
    end
  end
end
