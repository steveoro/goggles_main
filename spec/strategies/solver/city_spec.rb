# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::City, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'City', described_class)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'City')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'city_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'City')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'city' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'City')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'city_id' => row.id } },
    ->(row) { { 'city' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        solver = Solver::Factory.for('City', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::City.first(50).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::City)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'city_name' => row.name,
        'city_country_code' => row.country_code
      }
    },
    # depth 1
    lambda { |row|
      {
        'city' => {
          'name' => row.name,
          'country_code' => row.country_code
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index})," do
      subject do
        solver = Solver::Factory.for('City', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::City.first(50).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::City)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.name).to eq(fixture_row.name)
        end

        it 'has the expected country_code' do
          expect(subject.entity.country_code).to eq(fixture_row.country_code)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    #
    # VALID data: NEW row data
    #
    context "with solvable NEW #req data (valid @ depth #{index})," do
      subject do
        solver = Solver::Factory.for('City', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { FactoryBot.build(:city) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::City)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.name).to eq(fixture_row.name)
        end

        it 'has the expected country_code' do
          expect(subject.entity.country_code).to eq(fixture_row.country_code)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
