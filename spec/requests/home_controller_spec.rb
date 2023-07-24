# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  include ActiveJob::TestHelper

  before { expect(fixture_user).to be_a(GogglesDb::User).and be_valid }

  let(:fixture_user) { GogglesDb::User.first(50).sample }

  describe 'GET /index' do
    it 'returns http success' do
      get(home_index_path)
      expect(response).to have_http_status(:success)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /about' do
    it 'returns http success' do
      get(home_about_path)
      expect(response).to have_http_status(:success)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /contact_us' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(home_contact_us_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before { sign_in(fixture_user) }

      it 'returns http success' do
        get(home_contact_us_path)
        expect(response).to have_http_status(:success)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'POST /contact_us' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        post(home_contact_us_path, params: { body: 'Thou shall not send this...' })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user' do
      before do
        sign_in(fixture_user)
        # Remove mailer queue remnants from previous possible user confirmation emails:
        ActionMailer::Base.deliveries.clear
      end

      context 'without a body parameter,' do
        before { post(home_contact_us_path) }

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

        before do
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

  describe 'GET /reactivate' do
    it 'returns http success' do
      get(home_reactivate_path)
      expect(response).to have_http_status(:success)
    end
  end

  shared_examples_for('successful POST /reactivate with redirect and a message') do |flash_key, i18n_msg_key|
    it 'redirects to the root_path' do
      expect(response).to redirect_to(root_path)
    end

    it "sets a #{flash_key} flash message (#{i18n_msg_key.titleize})" do
      expect(flash[flash_key]).to eq(I18n.t("devise.customizations.reactivation.msg.#{i18n_msg_key}"))
    end
  end

  describe 'POST /reactivate' do
    context 'without an email parameter,' do
      before { post(home_reactivate_path) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets a warning flash message (Email empty)' do
        expect(flash[:warning]).to eq(I18n.t('devise.customizations.reactivation.msg.error_email_empty'))
      end

      it 'does not create a new issue request' do
        expect { post(home_reactivate_path) }.not_to change(GogglesDb::Issue, :count)
      end
    end

    context 'with a valid email but from an account which is still active,' do
      before { post(home_reactivate_path, params:) }

      let(:params) { { user: { email: GogglesDb::User.first.email } } }

      it_behaves_like('successful POST /reactivate with redirect and a message', :warning, 'error_not_deactivated')

      it 'does not create a new issue request' do
        expect(GogglesDb::Issue.exists?(user_id: GogglesDb::User.first.id, code: '5')).to be false
      end
    end

    context 'with a non-existing email,' do
      before { post(home_reactivate_path, params:) }

      let(:params) { { user: { email: 'not-an-email@for-sure' } } }

      it_behaves_like('successful POST /reactivate with redirect and a message', :warning, 'error_not_existing')

      it 'does not create a new issue request' do
        expect(GogglesDb::Issue.exists?(user_id: 'not-an-email@for-sure', code: '5')).to be false
      end
    end

    context 'with a valid email from a deactivated account,' do
      before do
        deactivated_user.active = false
        deactivated_user.save!
        post(home_reactivate_path, params:)
      end

      let(:deactivated_user) { GogglesDb::User.last(10).sample }
      let(:params) { { user: { email: deactivated_user.email } } }

      it_behaves_like('successful POST /reactivate with redirect and a message', :info, 'ok_sent')

      it 'creates a new issue request for the user' do
        expect(GogglesDb::Issue.exists?(user_id: deactivated_user.id, code: '5')).to be true
      end
    end

    context 'with a valid email from a deactivated account that has already issued a reactivation request,' do
      before do
        deactivated_user.active = false
        deactivated_user.save!
        GogglesDb::Issue.create!(user_id: deactivated_user.id, code: '5', req: '{}')
        post(home_reactivate_path, params:)
      end

      let(:deactivated_user) { GogglesDb::User.last(10).sample }
      let(:params) { { user: { email: deactivated_user.email } } }

      it_behaves_like('successful POST /reactivate with redirect and a message', :warning, 'error_already_requested')

      it 'does not create a duplicate issue request' do
        expect(GogglesDb::Issue.where(user_id: deactivated_user.id, code: '5').count).to eq(1)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET /dashboard' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(home_dashboard_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user without an associated swimmer,' do
      before do
        user = FactoryBot.create(:user)
        sign_in(user)
      end

      it 'is successful' do
        get(home_dashboard_path)
        expect(response).to have_http_status(:success)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
