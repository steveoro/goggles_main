# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportQueueDecorator do
  describe '#state_flag' do
    context 'for a row which is done (but not yet deleted),' do
      let(:model_obj) { FactoryBot.create(:import_queue, done: true) }
      subject { described_class.decorate(model_obj) }
      it 'returns a green dot' do
        expect(subject.state_flag).to eq('🟢')
      end
    end

    context "for a row which hasn\'t been processed yet," do
      let(:model_obj) { FactoryBot.create(:import_queue) }
      subject { described_class.decorate(model_obj) }
      it 'returns an empty string' do
        expect(subject.state_flag).to be_a(String).and be_empty
      end
    end

    context 'for a row that has already been processed at least once,' do
      let(:model_obj) { FactoryBot.create(:import_queue, process_runs: 1) }
      subject { described_class.decorate(model_obj) }
      it 'returns the counter of runs' do
        expect(subject.state_flag).to eq('▶ 1')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  let(:fixture_swimmer) { FactoryBot.build(:swimmer) }
  let(:fixture_event_type) { GogglesDb::EventType.all.sample }

  describe '#text_label' do
    let(:minutes) { (rand * 5).to_i }
    let(:seconds) { (rand * 59).to_i }
    let(:hundredths) { (rand * 99).to_i }
    let(:meters) { 50 + (rand * 8).to_i * 50 }
    let(:timing_request_data) do
      {
        'target_entity' => 'Lap',
        'lap' => {
          'swimmer' => { 'complete_name' => fixture_swimmer.complete_name },
          'meeting_individual_result' => {
            'event_type_id' => fixture_event_type.id
          },
          'length_in_meters' => meters,
          'minutes' => minutes,
          'seconds' => seconds,
          'hundredths' => hundredths
        }
      }.to_json
    end
    before(:each) do
      expect(fixture_swimmer).to be_a(GogglesDb::Swimmer)
      expect(fixture_event_type).to be_a(GogglesDb::EventType).and be_valid
      expect(timing_request_data).to be_a(String).and be_present
    end

    context 'for a row that contains a valid parent chrono timing,' do
      let(:fixture_row) { FactoryBot.create(:import_queue, uid: 'chrono', request_data: timing_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'includes a chrono icon' do
        expect(subject.text_label).to include('⏱')
      end
      it 'includes the timing from the request data' do
        expect(subject.text_label).to include(fixture_row.req_timing.to_s)
      end
      it 'includes the event type from the request data' do
        expect(subject.text_label).to include(fixture_row.req_event_type&.label)
      end
      it 'includes the swimmer name from the request data' do
        expect(subject.text_label).to include(fixture_row.req_swimmer_name)
      end
    end

    context 'for a row that contains a valid sibling chrono timing,' do
      let(:fixture_row) { FactoryBot.create(:import_queue, uid: 'chrono-1', request_data: timing_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'includes the timing from the request data' do
        expect(subject.text_label).to include(fixture_row.req_timing.to_s)
      end
      it 'includes the length in meters from the request data' do
        expect(subject.text_label).to include(meters.to_s)
      end
      it 'does not include the swimmer name' do
        expect(subject.text_label).not_to include(fixture_row.req_swimmer_name)
      end
    end

    context 'for a row that contains valid meeting reservation data,' do
      let(:fixture_row) { FactoryBot.create(:import_queue, uid: 'res', request_data: timing_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'includes a pin icon' do
        expect(subject.text_label).to include('📌')
      end
      it 'includes the timing from the request data' do
        expect(subject.text_label).to include(fixture_row.req_timing.to_s)
      end
      it 'includes the event type from the request data' do
        expect(subject.text_label).to include(fixture_row.req_event_type&.label)
      end
      it 'includes the swimmer name from the request data' do
        expect(subject.text_label).to include(fixture_row.req_swimmer_name)
      end
      it 'includes the user name that created the request' do
        expect(subject.text_label).to include(fixture_row.user.name)
      end
    end

    context 'for a generic row that contains any other entity data,' do
      let(:fixture_row) { FactoryBot.create(:import_queue, request_data: timing_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'includes the target entity name of the request' do
        expect(subject.text_label).to include(fixture_row.target_entity)
      end
      it 'includes the user name that created the request' do
        expect(subject.text_label).to include(fixture_row.user.name)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#req_swimmer_year_of_birth' do
    before(:each) do
      expect(fixture_swimmer).to be_a(GogglesDb::Swimmer)
      expect(fixture_event_type).to be_a(GogglesDb::EventType).and be_valid
    end

    context 'for a row that contains birth year data nested under a Swimmer node at depth 1,' do
      let(:fixture_request_data) do
        {
          'target_entity' => 'Whatever',
          'whatever' => {
            'swimmer' => {
              'complete_name' => fixture_swimmer.complete_name,
              'year_of_birth' => fixture_swimmer.year_of_birth
            }
          }
        }.to_json
      end
      let(:fixture_row) { FactoryBot.create(:import_queue, request_data: fixture_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'returns the year of birth of the swimmer' do
        expect(subject.req_swimmer_year_of_birth).to eq(fixture_swimmer.year_of_birth)
      end
    end

    context 'for a row that contains birth year data nested at root level,' do
      let(:fixture_request_data) do
        {
          'target_entity' => 'Swimmer',
          'swimmer' => {
            'complete_name' => fixture_swimmer.complete_name,
            'year_of_birth' => fixture_swimmer.year_of_birth
          }
        }.to_json
      end
      let(:fixture_row) { FactoryBot.create(:import_queue, request_data: fixture_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'returns the year of birth of the swimmer' do
        expect(subject.req_swimmer_year_of_birth).to eq(fixture_swimmer.year_of_birth)
      end
    end

    context "for a row that doesn't contain any birth year data," do
      let(:fixture_request_data) do
        {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => (rand * 150).to_i } # (Don't care if it's existing or not)
        }.to_json
      end
      let(:fixture_row) { FactoryBot.create(:import_queue, request_data: fixture_request_data) }
      subject { described_class.decorate(fixture_row) }

      it 'is nil' do
        expect(subject.req_swimmer_year_of_birth).to be nil
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
