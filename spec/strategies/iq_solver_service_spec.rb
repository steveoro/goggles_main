# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IqSolverService, type: :service do
  shared_examples_for 'IqSolverService valid instance' do
    it 'is an instance of the service' do
      expect(subject).to be_an(IqSolverService)
    end
    it 'responds to call' do
      expect(subject).to respond_to(:call)
    end
  end

  shared_examples_for 'IqSolverService called with a solvable row' do
    it_behaves_like('IqSolverService valid instance')
    describe '#call' do
      it 'returns true (updates the row)' do
        result = subject.call(solvable_row)
        expect(result).to be true
      end
      it 'sets #done to true' do
        subject.call(solvable_row)
        expect(solvable_row.reload.done).to be true
      end
      it 'increases #process_runs' do
        old_value = solvable_row.reload.process_runs
        subject.call(solvable_row)
        expect(solvable_row.reload.process_runs).to eq(old_value + 1)
      end
      it 'sets #solved_data to a non-empty JSON hash (with the solved bindings)' do
        subject.call(solvable_row)
        expect(solvable_row.reload.solved_data).to be_present
        expect(JSON.parse(solvable_row.solved_data)).to be_an(Hash)
      end
    end
  end

  shared_examples_for 'IqSolverService called with an unsolvable row' do
    it_behaves_like('IqSolverService valid instance')
    describe '#call' do
      it 'returns true (updates the row)' do
        result = subject.call(unsolvable_row)
        expect(result).to be true
      end
      it 'sets #done to false' do
        subject.call(unsolvable_row)
        expect(unsolvable_row.reload.done).to be false
      end
      it 'increases #process_runs' do
        old_value = unsolvable_row.reload.process_runs
        subject.call(unsolvable_row)
        expect(unsolvable_row.reload.process_runs).to eq(old_value + 1)
      end
      it 'sets #solved_data to a non-empty JSON hash (with the solved bindings)' do
        subject.call(unsolvable_row)
        expect(unsolvable_row.reload.solved_data).to be_present
        expect(JSON.parse(unsolvable_row.solved_data)).to be_an(Hash)
      end
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  context "when given a row marked already as 'done'," do
    let(:solved_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => GogglesDb::Swimmer.select(:id).first(150).sample.id }
        }.to_json,
        done: true
      )
    end
    subject { described_class.new }
    before(:each) { expect(solved_row).to be_a(GogglesDb::ImportQueue).and be_valid }

    it_behaves_like('IqSolverService valid instance')

    it 'ignores the row (returning nil)' do
      expect(subject.call(solved_row)).to be nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when given a solvable row (FINDER),' do
    let(:solvable_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => GogglesDb::Swimmer.select(:id).first(150).sample.id }
        }.to_json
      )
    end
    subject { described_class.new }
    before(:each) { expect(solvable_row).to be_a(GogglesDb::ImportQueue).and be_valid }

    it_behaves_like('IqSolverService called with a solvable row')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when given a solvable row (CREATOR),' do
    let(:solvable_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => {
            'complete_name' => 'Not An Existing Swimmer Indeed',
            'year_of_birth' => 1980 + (rand * 40).to_i,
            'gender_type_id' => [1, 2].sample
          }
        }.to_json
      )
    end
    subject { described_class.new }
    before(:each) { expect(solvable_row).to be_a(GogglesDb::ImportQueue).and be_valid }

    it_behaves_like('IqSolverService called with a solvable row')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when given a partially solvable row (missing data),' do
    let(:unsolvable_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => {
            'complete_name' => 'Not An Existing Swimmer Indeed'
            # no year_of_birth
            # no gender_type_id
          }
        }.to_json
      )
    end
    subject { described_class.new }
    before(:each) { expect(unsolvable_row).to be_a(GogglesDb::ImportQueue).and be_valid }

    it_behaves_like('IqSolverService called with an unsolvable row')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when given an unsolvable row (wrong bindings),' do
    let(:unsolvable_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => -1 }
        }.to_json
      )
    end
    before(:each) { expect(unsolvable_row).to be_a(GogglesDb::ImportQueue).and be_valid }

    it_behaves_like('IqSolverService called with an unsolvable row')
  end
  #-- -------------------------------------------------------------------------
  #++
end
