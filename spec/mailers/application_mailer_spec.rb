# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer do
  include ActiveJob::TestHelper

  let(:user) { GogglesDb::User.first(50).sample }
  let(:email_subject) { FFaker::Lorem.sentence }
  # EMail bodies are enconded: any text longer than 73 chanraters will be split in multiple lines
  # separated by '+' & '='. We need to stick to a short text to simplify the tests:
  let(:email_content) { FFaker::Lorem.sentence[0..72] }

  describe 'self.generic_message' do
    shared_examples_for 'ApplicationMailer.generic_message email common fields' do
      it 'enqueues a mailers job when delivered later' do
        expect { mail.deliver_later }.to have_enqueued_job.on_queue('mailers')
      end

      it 'renders the specified headers' do
        expect(mail.subject).to include(email_subject)
        expect(mail.to).to include(user.email)
        expect(mail.from.first).to include("no-reply@#{ApplicationMailer::HOSTNAME}")
      end

      it 'renders the specified body content' do
        expect(mail.body.encoded).to include(ERB::Util.html_escape(email_content.html_safe))
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'when using all parameters,' do
      let(:mail) do
        described_class.generic_message(
          user_email: user.email,
          user_name: user.name,
          subject_text: email_subject,
          content_body: email_content
        )
      end

      it_behaves_like('ApplicationMailer.generic_message email common fields')

      it 'shows a greetings for the user name' do
        expect(mail.body.encoded).to include(
          I18n.t('devise.mailer.email_changed.greeting', recipient: user.name.titleize)
        )
      end
    end

    context 'when giving a nil user_name,' do
      let(:mail) do
        described_class.generic_message(
          user_email: user.email,
          subject_text: email_subject,
          content_body: email_content
        )
      end

      it_behaves_like('ApplicationMailer.generic_message email common fields')

      it 'does not show the greetings section' do
        expect(mail.body.encoded).not_to include(
          I18n.t('devise.mailer.email_changed.greeting', recipient: user.name.titleize)
        )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.system_message' do
    let(:to_address) { FFaker::Internet.email }
    let(:cc_address) { FFaker::Internet.email }

    shared_examples_for 'ApplicationMailer.system_message email common fields' do
      it 'enqueues a mailers job when delivered later' do
        expect { mail.deliver_later }.to have_enqueued_job.on_queue('mailers')
      end

      it 'renders the specified headers' do
        expect(mail.subject).to include(email_subject).and include('[SYS]')
        expect(mail.to).to include(to_address)
        expect(mail.cc).to include(cc_address)
        expect(mail.from.first).to include("no-reply@#{ApplicationMailer::HOSTNAME}")
      end

      it 'renders the specified body content' do
        expect(mail.body.encoded).to include(ERB::Util.html_escape(email_content.html_safe))
      end
    end

    context 'when using all parameters,' do
      let(:mail) do
        described_class.system_message(
          user: user,
          to_address: to_address,
          cc_address: cc_address,
          subject_text: email_subject,
          content_body: email_content
        )
      end

      it_behaves_like('ApplicationMailer.system_message email common fields')

      it 'shows the details of the specified user instance' do
        expect(mail.body.encoded).to include('*** Involved User: ***')
          .and include("id: #{user.id}")
          .and include("name: #{user.name}")
          .and include("first_name: #{user.first_name}")
          .and include("last_name: #{user.last_name}")
          .and include("description: #{user.description}")
          .and include("swimmer_id: #{user.swimmer_id}")
      end
    end

    context 'when giving a nil user_name,' do
      let(:mail) do
        described_class.system_message(
          user: nil,
          to_address: to_address,
          cc_address: cc_address,
          subject_text: email_subject,
          content_body: email_content
        )
      end

      it_behaves_like('ApplicationMailer.system_message email common fields')

      it 'does not show the user detail section' do
        expect(mail.body.encoded).not_to include('*** Involved User: ***')
      end
    end
  end
end
