# frozen_string_literal: true

require 'rails_helper'
require GogglesDb::Engine.root.join('spec', 'support', 'shared_method_existance_examples')

RSpec.describe IqRequest::ChronoRecParamAdapter do
  # Domain definition:
  let(:current_user) { GogglesDb::User.first(50).sample }
  let(:base_date) { Time.zone.today }
  let(:event_date) { base_date.to_s }
  let(:fixture_swimmer) { GogglesDb::Swimmer.first(150).sample }
  let(:fixture_pool) { GogglesDb::SwimmingPool.first(50).sample }
  let(:fixture_event) { GogglesDb::EventsByPoolType.eventable.individuals.sample.event_type }
  let(:fixture_category) { GogglesDb::CategoryType.eventable.individuals.sample }

  # Minimalistic example:
  let(:fixture_params) do
    {
      'rec_type' => '2', # workshop
      'meeting_id' => '',
      'meeting_label' => '',
      'user_workshop_id' => '0', # new workshop
      'user_workshop_label' => 'CSI at home 2021 - test',
      'swimming_pool_label' => fixture_pool.name,
      'swimming_pool_id' => fixture_pool.id.to_s,
      'event_date' => Time.zone.today.to_s,
      'event_type_label' => fixture_event.code,
      'event_type_id' => fixture_event.id.to_s,
      'pool_type_id' => fixture_pool.pool_type_id.to_s,
      'swimmer_label' => fixture_swimmer.complete_name,
      'swimmer_id' => fixture_swimmer.id.to_s,
      'swimmer_gender_type_id' => fixture_swimmer.gender_type_id.to_s,
      'category_type_label' => fixture_category.code,
      'category_type_id' => fixture_category.id.to_s
    }
  end
  let(:fixture_rec_data) do
    {
      'length_in_meters' => fixture_event.length_in_meters.to_s,
      'reaction_time' => rand.round(2),
      'minutes' => 0,
      'seconds' => ((rand * 59) % 59).to_i,
      'hundredths' => ((rand * 99) % 99).to_i,
      'position' => (1..10).to_a.sample,
      'minutes_from_start' => 1,
      'seconds_from_start' => ((rand * 59) % 59).to_i,
      'hundredths_from_start' => ((rand * 99) % 99).to_i
    }
  end

  # Fixture request_data (JSON-ified) that includes a recorded timing:
  let(:minutes) { (rand * 5).to_i }
  let(:seconds) { (rand * 59).to_i }
  let(:hundredths) { (rand * 99).to_i }
  let(:meters) { 50 + ((rand * 8).to_i * 50) }
  let(:order) { 1 + (rand * 8).to_i }
  let(:rec_data_hash) do
    {
      'order' => order,
      'length_in_meters' => meters,
      'minutes' => minutes,
      'seconds' => seconds,
      'hundredths' => hundredths
    }
  end
  let(:recdetail_min_request_data) do
    {
      'target_entity' => 'Lap',
      'lap' => {
        'swimmer' => { 'complete_name' => fixture_swimmer.complete_name },
        'meeting_individual_result' => {
          'user_id' => current_user.id,
          'event_type_id' => fixture_event.id
        }
      }
    }.to_json
  end

  before do
    expect(current_user).to be_a(GogglesDb::User).and be_valid
    expect(fixture_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    expect(fixture_pool).to be_a(GogglesDb::SwimmingPool).and be_valid
    expect(fixture_event).to be_an(GogglesDb::EventType).and be_valid
    expect(fixture_category).to be_a(GogglesDb::CategoryType).and be_valid
    expect(rec_data_hash).to be_a(Hash).and be_present
    expect(recdetail_min_request_data).to be_a(String).and be_present
  end
  #-- -------------------------------------------------------------------------
  #++

  # REQUIRES: subject
  shared_examples_for 'a valid ChronoRecParamAdapter instance' do
    it 'is a ChronoRecParamAdapter instance' do
      expect(subject).to be_a(described_class)
    end

    it_behaves_like(
      'responding to a list of methods',
      %i[
        params rec_data target_entity
        root_key result_parent_key root_request_hash
        to_request_hash update_rec_detail_data update_result_data
        header_year rec_type_meeting? rec_type_workshop?
        chrono_swimmer_label chrono_event_label
        chrono_event_container_label chrono_swimming_pool_label
      ]
    )

    it_behaves_like(
      'responding to a list of class methods',
      %i[
        from_request_data
      ]
    )

    describe '#root_key' do
      it 'is the snake-case name corresponding to the root depth level key' do
        expect(subject.root_key).to eq(subject.target_entity.tableize.singularize)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#new' do
    context 'with invalid parameters,' do
      it 'raises an ArgumentError for an invalid source object' do
        expect { described_class.new(current_user, nil) }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError for an invalid current user' do
        expect { described_class.new(nil, {}) }.to raise_error(ArgumentError)
      end
    end

    context 'with valid parameters but no detail rec_data,' do
      subject { described_class.new(current_user, fixture_params) }

      it_behaves_like('a valid ChronoRecParamAdapter instance')

      describe '#params' do
        subject { described_class.new(current_user, example_params_hash) }

        let(:example_params_hash) { { 'rec_type' => Switch::XorComponent::TYPE_TARGET1 } }

        it 'is an Hash' do
          expect(subject.params).to be_an(Hash)
        end

        it 'is the params_hash specified in the constructor' do
          expect(subject.params).to eq(example_params_hash)
        end
      end

      context 'when #rec_type is set to TYPE_TARGET1 (meeting) in the params_hash,' do
        subject { described_class.new(current_user, example_params_hash) }

        let(:example_params_hash) { { 'rec_type' => Switch::XorComponent::TYPE_TARGET1 } }

        describe '#target_entity' do
          it 'is Lap' do
            expect(subject.target_entity).to eq('Lap')
          end
        end

        describe '#result_parent_key' do
          it 'is meeting_individual_result' do
            expect(subject.result_parent_key).to eq('meeting_individual_result')
          end
        end
      end

      context 'when #rec_type is set to TYPE_TARGET2 (workshop) in the params_hash,' do
        subject { described_class.new(current_user, example_params_hash) }

        let(:example_params_hash) { { 'rec_type' => Switch::XorComponent::TYPE_TARGET2 } }

        describe '#target_entity' do
          it 'is UserLap' do
            expect(subject.target_entity).to eq('UserLap')
          end
        end

        describe '#result_parent_key' do
          it 'is user_result' do
            expect(subject.result_parent_key).to eq('user_result')
          end
        end
      end

      context 'when #rec_type is not set at all,' do
        subject { described_class.new(current_user, example_params_hash) }

        let(:example_params_hash) { { 'anything_else' => 0 } }

        describe '#target_entity' do
          it 'defaults to Lap' do
            expect(subject.target_entity).to eq('Lap')
          end
        end

        describe '#result_parent_key' do
          it 'defaults to meeting_individual_result' do
            expect(subject.result_parent_key).to eq('meeting_individual_result')
          end
        end
      end

      describe '#to_request_hash' do
        subject { described_class.new(current_user, example_params_hash) }

        let(:example_params_hash) do
          {
            'rec_type' => [Switch::XorComponent::TYPE_TARGET1, Switch::XorComponent::TYPE_TARGET2].sample
          }
        end

        it 'is an Hash' do
          expect(subject.to_request_hash).to be_an(Hash)
        end

        it 'includes the target_entity' do
          expect(subject.to_request_hash).to have_key('target_entity')
        end

        it 'includes the root_key' do
          expect(subject.to_request_hash).to have_key(subject.root_key)
        end
      end
      #-- ---------------------------------------------------------------------
      #++

      describe '#chrono_swimmer_label' do
        subject { described_class.new(current_user, fixture_params) }

        it 'is an String' do
          expect(subject.chrono_swimmer_label).to be_a(String).and be_present
        end

        it 'includes both the swimmer_label & the category_type_label' do
          expect(subject.chrono_swimmer_label).to include(subject.params.fetch('swimmer_label', nil))
            .and include(subject.params.fetch('category_type_label', nil))
        end
      end

      describe '#chrono_event_label' do
        subject { described_class.new(current_user, fixture_params) }

        it 'is an String' do
          expect(subject.chrono_event_label).to be_a(String).and be_present
        end

        it 'includes both the event_date & the event_type_label' do
          expect(subject.chrono_event_label).to include(subject.params.fetch('event_date', nil))
            .and include(subject.params.fetch('event_type_label', nil))
        end
      end

      describe '#chrono_event_container_label' do
        subject { described_class.new(current_user, fixture_params) }

        it 'is an String' do
          expect(subject.chrono_event_container_label).to be_a(String).and be_present
        end

        it 'includes the meeting_label or the workshop_label (which one is defined first)' do
          expect(subject.chrono_event_container_label).to include(subject.params.fetch('meeting_label', nil))
            .or include(subject.params.fetch('user_workshop_label', nil))
        end
      end

      describe '#chrono_swimming_pool_label' do
        subject { described_class.new(current_user, fixture_params) }

        it 'is an String' do
          expect(subject.chrono_swimming_pool_label).to be_a(String).and be_present
        end

        it 'includes the meeting_label or the workshop_label (which one is defined first)' do
          expect(subject.chrono_swimming_pool_label).to include(subject.params.fetch('swimming_pool_label', nil))
        end
      end
      #-- ---------------------------------------------------------------------
      #++

      describe '#header_year' do
        context 'when it is set in the source object,' do
          subject { described_class.new(current_user, source_params) }

          let(:expected_result) { "#{Time.zone.today.year - 2}..#{Time.zone.today.year}" }
          let(:source_params) { { 'header_year' => expected_result } }

          it 'equals the specified value' do
            expect(subject.header_year).to eq(expected_result)
          end
        end

        context 'when event_date is set but header_year is not,' do
          subject { described_class.new(current_user, source_params) }

          let(:source_params) { { 'event_date' => event_date } }

          it 'includes the year of the specified date' do
            expect(subject.header_year).to include(base_date.year.to_s)
          end

          it 'has a dual-year format (YYYY/YYYY+1), depending on the base date' do
            if base_date.month > 8
              expect(subject.header_year).to eq("#{base_date.year}/#{base_date.year + 1}")
            else
              expect(subject.header_year).to eq("#{base_date.year - 1}/#{base_date.year}")
            end
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.from_request_data' do
    context 'with an invalid parameter,' do
      let(:fixture_request) { 'not a valid JSON string' }

      it 'raises an JSON parse error' do
        expect { described_class.from_request_data(fixture_request) }.to raise_error(ActiveSupport::JSON.parse_error)
      end
    end

    context 'with valid JSON hash that does not contain a valid user_id,' do
      let(:fixture_request) { { 'target_entity' => 'Lap' }.to_json }

      it 'raises an Argument error' do
        expect { described_class.from_request_data(fixture_request) }.to raise_error(ArgumentError)
      end
    end

    %w[UserLap Lap].each do |target_entity|
      context "with a valid JSON hash (for a '#{target_entity}' target)," do
        subject { described_class.from_request_data(request_hash.to_json) }

        let(:request_hash) { { 'target_entity' => target_entity, 'user_id' => 1 } }

        before do
          expect(request_hash['target_entity']).to eq(target_entity)
        end

        it_behaves_like('a valid ChronoRecParamAdapter instance')

        describe '#params' do
          it 'is empty' do
            expect(subject.params).to be_empty
          end
        end

        describe '#target_entity' do
          it 'is the target_entity set in the request' do
            expect(subject.target_entity).to eq(request_hash['target_entity'])
          end
        end

        describe '#root_request_hash' do
          it 'is nil if the root_key is not present is the source request' do
            expect(subject.root_request_hash).to be nil
          end
        end

        describe '#rec_type_meeting?' do
          it 'is true for a Lap target_entity and false for UserLap' do
            expect(subject.rec_type_meeting?).to eq(target_entity == 'Lap')
          end
        end

        describe '#rec_type_workshop?' do
          it 'is true for a UserLap target_entity and false for Lap' do
            expect(subject.rec_type_workshop?).to eq(target_entity == 'UserLap')
          end
        end

        describe '#to_request_hash' do
          it 'is the source request' do
            expect(subject.to_request_hash).to eq(request_hash)
          end
        end

        describe '#header_year' do
          it 'is nil if the header_year is not present is the source request' do
            expect(subject.header_year).to be nil
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  shared_examples_for '#update_rec_detail_data or #update_result_data with no #request_hash' do
    it 'has a nil #request_hash' do
      expect(subject.request_hash).to be nil
    end

    it 'updates or overwrites #rec_data with the timing data specified into rec_data_hash' do
      # Changes in result: rec_data will have the new specified values (including any missing keys)
      rec_data_hash.each do |key, value|
        expect(subject.rec_data).to have_key(key)
        expect(subject.rec_data[key]).to eq(value)
      end
    end
  end

  describe '#update_rec_detail_data' do
    context 'when no #rec_data or #request_hash are set,' do
      subject { described_class.new(current_user, {}) }

      before do
        expect(subject.rec_data).to be_an(Hash).and be_empty
        expect(subject.request_hash).to be nil
        # Run the update method:
        subject.update_rec_detail_data({ order: 1 })
      end

      it 'does nothing (not changing #rec_data nor #request_hash)' do
        # No changes in result:
        expect(subject.rec_data).to be_an(Hash).and be_empty
        expect(subject.request_hash).to be nil
      end
    end

    context 'when #request_hash is set (by self.from_request_data),' do
      subject { described_class.from_request_data(recdetail_min_request_data) }

      before do
        expect(subject.rec_data).to be_an(Hash).and be_empty
        expect(subject.request_hash).to be_an(Hash).and be_present
        expect(subject.request_hash['lap']).to be_an(Hash).and be_present
        rec_data_hash.each_key do |key|
          expect(subject.request_hash['lap']).not_to have_key(key)
        end
        # Run the update method:
        subject.update_rec_detail_data(rec_data_hash)
      end

      it 'updates #request_hash (at detail level) with the timing data specified into rec_data_hash' do
        # Changes in result: request_hash will have the new specified values (including any missing keys)
        rec_data_hash.each do |key, value|
          expect(subject.request_hash['lap']).to have_key(key)
          expect(subject.request_hash['lap'][key]).to eq(value)
        end
        expect(subject.rec_data).to be_an(Hash).and be_empty
      end
    end

    context 'when #rec_data is set by the constructor,' do
      subject { described_class.new(current_user, fixture_params, fixture_rec_data) }

      before do
        expect(subject.request_hash).to be nil
        expect(subject.rec_data).to be_an(Hash).and be_present
        # Domain check:
        fixture_rec_data.each do |key, value|
          expect(subject.rec_data).to have_key(key)
          expect(subject.rec_data[key]).to eq(value)
        end
        # This shall be added by rec_data_hash:
        expect(subject.rec_data).not_to have_key('order')
        # Run the update method:
        subject.update_rec_detail_data(rec_data_hash)
      end

      it_behaves_like('#update_rec_detail_data or #update_result_data with no #request_hash')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#update_result_data' do
    context 'when no #rec_data or #request_hash are set,' do
      subject { described_class.new(current_user, {}) }

      before do
        expect(subject.rec_data).to be_an(Hash).and be_empty
        expect(subject.request_hash).to be nil
        # Run the update method:
        subject.update_result_data({ order: 1 })
      end

      it 'does nothing (not changing #rec_data nor #request_hash)' do
        # No changes in result:
        expect(subject.rec_data).to be_an(Hash).and be_empty
        expect(subject.request_hash).to be nil
      end
    end

    context 'when #request_hash is set (by self.from_request_data),' do
      subject { described_class.from_request_data(recdetail_min_request_data) }

      before do
        expect(subject.rec_data).to be_an(Hash).and be_empty
        # Domain check:
        expect(subject.request_hash).to be_an(Hash).and be_present
        expect(subject.request_hash['lap']).to be_an(Hash).and be_present
        expect(subject.request_hash['lap']['meeting_individual_result']).to be_an(Hash).and be_present
        rec_data_hash.each_key do |key|
          expect(subject.request_hash['lap']).not_to have_key(key)
          expect(subject.request_hash['lap']['meeting_individual_result']).not_to have_key(key)
        end
        # Run the update method:
        subject.update_result_data(rec_data_hash)
      end

      it 'updates #request_hash (at result level) with the timing data specified into rec_data_hash' do
        # Changes in result: request_hash will have the new specified values (including any missing keys)
        rec_data_hash.each do |key, value|
          expect(subject.request_hash['lap']).not_to have_key(key)
          expect(subject.request_hash['lap']['meeting_individual_result']).to have_key(key)
          expect(subject.request_hash['lap']['meeting_individual_result'][key]).to eq(value)
        end
        expect(subject.rec_data).to be_an(Hash).and be_empty
      end
    end

    context 'when #rec_data is set by the constructor,' do
      subject { described_class.new(current_user, fixture_params, fixture_rec_data) }

      before do
        expect(subject.request_hash).to be nil
        expect(subject.rec_data).to be_an(Hash).and be_present
        # Domain check:
        fixture_rec_data.each do |key, value|
          expect(subject.rec_data).to have_key(key)
          expect(subject.rec_data[key]).to eq(value)
        end
        # This shall be added by rec_data_hash:
        expect(subject.rec_data).not_to have_key('order')

        # Run the update method:
        subject.update_result_data(rec_data_hash)
      end

      it_behaves_like('#update_rec_detail_data or #update_result_data with no #request_hash')
    end
  end
end
