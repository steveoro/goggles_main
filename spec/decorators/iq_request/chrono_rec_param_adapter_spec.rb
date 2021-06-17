# frozen_string_literal: true

require 'rails_helper'
require GogglesDb::Engine.root.join('spec', 'support', 'shared_method_existance_examples')

RSpec.describe IqRequest::ChronoRecParamAdapter do
  # Domain definition:
  let(:current_user) { GogglesDb::User.first(50).sample }
  let(:base_date) { Date.today }
  let(:event_date) { base_date.to_s }
  let(:fixture_swimmer) { GogglesDb::Swimmer.first(150).sample }
  let(:fixture_pool) { GogglesDb::SwimmingPool.first(50).sample }
  let(:fixture_event) { GogglesDb::EventsByPoolType.eventable.individuals.sample.event_type }
  let(:fixture_category) { GogglesDb::CategoryType.eventable.individuals.sample }

  before(:each) do
    expect(fixture_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    expect(fixture_pool).to be_a(GogglesDb::SwimmingPool).and be_valid
    expect(fixture_event).to be_an(GogglesDb::EventType).and be_valid
    expect(fixture_category).to be_a(GogglesDb::CategoryType).and be_valid
  end

  # Minimalistic example:
  let(:fixture_params) do
    {
      'rec_type' => '2', # workshop
      'meeting_id' => '',
      'meeting_label' => '',
      'user_workshop_id' => '0', # new workshop
      'user_workshop_label' => 'CSI at home 2021 - test',
      'swimming_pool_id' => fixture_pool.id.to_s,
      'event_date' => Date.today.to_s,
      'event_type_id' => fixture_event.id.to_s,
      'pool_type_id' => fixture_pool.pool_type_id.to_s,
      'swimmer_id' => fixture_swimmer.id.to_s,
      'swimmer_gender_type_id' => fixture_swimmer.gender_type_id.to_s,
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
  #-- -------------------------------------------------------------------------
  #++

  # REQUIRES: subject
  shared_examples_for 'a valid ChronoRecParamAdapter instance' do
    it 'is a ChronoRecParamAdapter instance' do
      expect(subject).to be_a(IqRequest::ChronoRecParamAdapter)
    end

    it_behaves_like(
      'responding to a list of methods',
      %i[
        params rec_data target_entity
        root_key root_request_hash
        to_request_hash update_rec_detail_data
        header_year rec_type_meeting? rec_type_workshop?
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
        let(:example_params_hash) { { 'rec_type' => 1 } }
        subject { described_class.new(current_user, example_params_hash) }
        it 'is an Hash' do
          expect(subject.params).to be_an(Hash)
        end
        it 'is the params_hash specified in the constructor' do
          expect(subject.params).to eq(example_params_hash)
        end
      end

      describe '#target_entity' do
        context 'when rec_type is set to TYPE_TARGET1 in the params_hash,' do
          let(:example_params_hash) { { 'rec_type' => Switch::XorComponent::TYPE_TARGET1 } }
          subject { described_class.new(current_user, example_params_hash) }
          it 'is Lap' do
            expect(subject.target_entity).to eq('Lap')
          end
        end
        context 'when rec_type is set to TYPE_TARGET2 in the params_hash,' do
          let(:example_params_hash) { { 'rec_type' => Switch::XorComponent::TYPE_TARGET2 } }
          subject { described_class.new(current_user, example_params_hash) }
          it 'is UserLap' do
            expect(subject.target_entity).to eq('UserLap')
          end
        end
        context 'when rec_type is not set at all,' do
          let(:example_params_hash) { { 'anything_else' => 0 } }
          subject { described_class.new(current_user, example_params_hash) }
          it 'defaults to Lap' do
            expect(subject.target_entity).to eq('Lap')
          end
        end
      end

      describe '#header_year' do
        context 'when it is set in the source object,' do
          let(:expected_result) { "#{Date.today.year - 2}..#{Date.today.year}" }
          let(:source_params) { { 'header_year' => expected_result } }
          subject { described_class.new(current_user, source_params) }

          it 'equals the specified value' do
            expect(subject.header_year).to eq(expected_result)
          end
        end

        context 'when event_date is set but header_year is not,' do
          let(:source_params) { { 'event_date' => event_date } }
          subject { described_class.new(current_user, source_params) }

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

      describe '#to_request_hash' do
        let(:example_params_hash) { { 'rec_type' => 1 } }
        subject { described_class.new(current_user, example_params_hash) }
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
      context 'with a valid JSON hash,' do
        let(:request_hash) { { 'target_entity' => target_entity, 'user_id' => 1 } }
        before(:each) do
          expect(request_hash['target_entity']).to eq(target_entity)
        end
        subject { described_class.from_request_data(request_hash.to_json) }

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
end
