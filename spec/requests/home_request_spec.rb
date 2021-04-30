# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  include ActiveJob::TestHelper

  describe 'GET /index' do
    it 'returns http success' do
      get(home_index_path)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /about' do
    it 'returns http success' do
      get(home_about_path)
      expect(response).to have_http_status(:success)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  let(:fixture_user) { GogglesDb::User.first(50).sample }
  before(:each) { expect(fixture_user).to be_a(GogglesDb::User).and be_valid }

  describe 'GET /contact_us' do
    context 'for an unlogged user' do
      it 'is a redirect to the login path' do
        get(home_contact_us_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a logged-in user' do
      before(:each) { sign_in(fixture_user) }
      it 'returns http success' do
        get(home_contact_us_path)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /contact_us' do
    context 'for an unlogged user' do
      it 'is a redirect to the login path' do
        post(home_contact_us_path, params: { body: 'Thou shall not send this...' })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'for a logged-in user' do
      before(:each) do
        sign_in(fixture_user)
        # Remove mailer queue remnants from previous possible user confirmation emails:
        ActionMailer::Base.deliveries.clear
      end

      context 'without a body parameter,' do
        before(:each) {  post(home_contact_us_path) }

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'does not change the mail queue' do
          expect { perform_enqueued_jobs }.not_to change(ActionMailer::Base.deliveries, :size)
        end
      end

      context 'with a valid body parameter,' do
        # EMail bodies are enconded: any text longer than 73 chanraters will be split in multiple lines
        # separated by '+' & '='. We need to stick to a short text to simplify the tests:
        let(:email_content) { FFaker::Lorem.sentence[0..72] }
        before(:each) do
          expect(email_content).to be_present
          post(home_contact_us_path, params: { body: email_content })
        end

        it 'succesfully redirects to the root_path' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets an ok flash message' do
          expect(flash[:info]).to eq(I18n.t('contact_us.message_sent'))
        end

        it 'sends out a [SYS]-type message to the maintainers' do
          perform_enqueued_jobs
          app_settings_row = GogglesDb::AppParameter.versioning_row
          mail = ActionMailer::Base.deliveries.last
          expect(mail.subject).to include('[SYS]')
          expect(mail.to.first).to eq(app_settings_row.settings(:framework_emails).contact)
          expect(mail.cc.first).to eq(app_settings_row.settings(:framework_emails).admin)
          expect(mail.from.first).to include("no-reply@#{ApplicationMailer::HOSTNAME}")
          expect(mail.body.encoded).to include(email_content)
        end

        it 'adds a new message to the mail queue' do
          expect { perform_enqueued_jobs }
            .to(change { ActionMailer::Base.deliveries.size }.by(1))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
