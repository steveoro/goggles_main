# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'chrono/index.html.haml', type: :view do
  let(:current_user) { GogglesDb::User.first(50).sample }
  let(:fixture_swimmer) { GogglesDb::Swimmer.first(150).sample }
  let(:fixture_event) { GogglesDb::EventsByPoolType.eventable.individuals.sample.event_type }
  let(:minutes) { (rand * 5).to_i }
  let(:seconds) { (rand * 59).to_i }
  let(:hundredths) { (rand * 99).to_i }
  let(:meters) { 50 + (rand * 8).to_i * 50 }

  before do
    expect(current_user).to be_a(GogglesDb::User).and be_valid
    expect(fixture_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    expect(fixture_event).to be_an(GogglesDb::EventType).and be_valid
  end

  shared_examples_for 'chrono/index.html.haml common rendering details' do
    it 'includes the title' do
      expect(subject.css('.main-content h4').text).to include(I18n.t('chrono.index.title'))
    end

    it 'includes the queue notice' do
      expect(subject.css('.main-content .container i').text).to include(I18n.t('chrono.index.queue_notice'))
    end

    it 'includes the registration notice' do
      expect(subject.css('.main-content .container p').text).to include(I18n.t('chrono.index.registration_notice'))
    end

    it 'includes the "new recording" button' do
      expect(subject.css('.main-content .container .btn').text).to include(I18n.t('chrono.buttons.new_recording'))
    end

    # The footer was removed because it was hiding the post button on very small screens like on the iPhone 4.
    it 'does not include the bottom footer section' do
      expect(rendered).not_to have_css('section.fixed-bottom#footer')
    end
  end

  context 'with a logged-in user, when there are *no* IQ rows for the current_user,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:fixture_row) { FactoryBot.create(:import_queue, user: current_user) }

    before do
      expect(fixture_row).to be_a(GogglesDb::ImportQueue).and be_valid
      @queues = GogglesDb::ImportQueue.for_user(current_user).for_uid('chrono')
      # [Steve A.] Stub Devise controller helper method before rendering because
      #            view specs do not have the @controller variable set.
      #            Also, sign-in the user using the included integration test helpers:
      sign_in(current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      render
    end

    it_behaves_like('chrono/index.html.haml common rendering details')

    it 'includes the no-data warning' do
      expect(subject.css('.main-content .container .row').text).to include(I18n.t('chrono.index.no_data_notice'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a logged-in user, when some IQ rows for the current_user are present,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:request_data) do
      {
        'target_entity' => 'UserLap',
        'user_lap' => {
          'swimmer' => {
            'complete_name' => fixture_swimmer.complete_name
            # (unsolvable: missing gender_type_id & year_of_birth)
          },
          'length_in_meters' => meters,
          'minutes' => minutes,
          'seconds' => seconds,
          'hundredths' => hundredths,
          'user_result' => {
            'user_id' => current_user.id,
            'event_type_id' => fixture_event.id
            # (unsolvable: missing user_workshop)
          }
        }
      }
    end
    let(:fixture_rows) { FactoryBot.create_list(:import_queue, 3, uid: 'chrono', request_data: request_data.to_json) }

    before do
      expect(request_data).to be_an(Hash).and be_present
      expect(fixture_rows).to all be_a(GogglesDb::ImportQueue).and be_valid
      @queues = GogglesDb::ImportQueue.for_user(current_user).for_uid('chrono')
      # [Steve A.] Stub Devise controller helper method before rendering because
      #            view specs do not have the @controller variable set.
      #            Also, sign-in the user using the included integration test helpers:
      sign_in(current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      render
    end

    it_behaves_like('chrono/index.html.haml common rendering details')

    it 'displays the same list of filtered IQ rows available to the user' do
      expect(subject.css('.main-content .container .row.border').count)
        .to eq(@queues.count)
    end

    it 'includes the list of IQ decorated rows' do
      GogglesDb::ImportQueueDecorator.decorate_collection(@queues).each do |queue|
        expect(subject.css('.main-content .container .row.border').text).to include(queue.text_label)
      end
    end

    it 'includes the delete button for the IQ rows' do
      @queues.each do |queue|
        expect(subject.css(".main-content .container .row.border #frm-delete-row-#{queue.id}")).to be_present
      end
    end
  end
end
