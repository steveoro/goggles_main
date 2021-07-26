# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::CategoryType, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder ONLY, before #solve!', 'CategoryType', Solver::CategoryType)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'CategoryType')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'category_type_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'CategoryType')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'category_type' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'CategoryType')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'category_type_id' => row.id } },
    ->(row) { { 'category_type' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::CategoryType.all.sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('CategoryType', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::CategoryType)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'category_type_code' => row.code,
        'season_id' => row.season_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'category_type' => {
          'code' => row.code,
          'season_id' => row.season_id
        }
      }
    },
    # mixed depth 1
    lambda { |row|
      {
        'category_type_code' => row.code,
        'season' => { 'id' => row.season_id }
      }
    },
    # depth 2
    lambda { |row|
      {
        'category_type' => {
          'code' => row.code,
          'season' => { 'id' => row.season_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::CategoryType.eventable.sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('CategoryType', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::CategoryType)

      describe '#entity' do
        it 'has the expected code' do
          expect(subject.entity.code).to eq(fixture_row.code)
        end
        it 'has the expected season_id' do
          expect(subject.entity.season_id).to eq(fixture_row.season_id)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
