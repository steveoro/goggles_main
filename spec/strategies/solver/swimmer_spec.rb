# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Swimmer, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'Swimmer', Solver::Swimmer)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'swimmer_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Swimmer')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'swimmer' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Swimmer')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'swimmer_id' => row.id } },
    ->(row) { { 'swimmer' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('Swimmer', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Swimmer)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'swimmer_complete_name' => row.complete_name,
        'year_of_birth' => row.year_of_birth,
        'gender_type_id' => row.gender_type_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'swimmer' => {
          'complete_name' => row.complete_name,
          'year_of_birth' => row.year_of_birth,
          'gender_type_id' => row.gender_type_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'swimmer' => {
          'complete_name' => row.complete_name,
          'year_of_birth' => row.year_of_birth,
          'gender_type' => { 'id' => row.gender_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('Swimmer', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Swimmer)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.complete_name).to eq(fixture_row.complete_name)
        end
        it 'has the expected year_of_birth' do
          expect(subject.entity.year_of_birth).to eq(fixture_row.year_of_birth)
        end
        it 'has the expected gender' do
          expect(subject.entity.gender_type_id).to eq(fixture_row.gender_type_id)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    #
    # VALID data: NEW row data
    #
    context "with solvable NEW #req data (valid @ depth #{index})," do
      let(:fixture_row) { FactoryBot.build(:swimmer) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        solver = Solver::Factory.for('Swimmer', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Swimmer)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.complete_name).to eq(fixture_row.complete_name)
        end
        it 'has the expected year_of_birth' do
          expect(subject.entity.year_of_birth).to eq(fixture_row.year_of_birth)
        end
        it 'has the expected gender' do
          expect(subject.entity.gender_type_id).to eq(fixture_row.gender_type_id)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
