# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::SwimmingPool, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'SwimmingPool', Solver::SwimmingPool)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'SwimmingPool')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'swimming_pool_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'SwimmingPool')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'swimming_pool' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'SwimmingPool')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'swimming_pool_id' => row.id } },
    ->(row) { { 'swimming_pool' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::SwimmingPool.first(50).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('SwimmingPool', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::SwimmingPool)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'swimming_pool_name' => row.name,
        'swimming_pool_nick_name' => row.nick_name,
        'city_id' => row.city_id,
        'pool_type_id' => row.pool_type_id
      }
    },
    lambda { |row| # check that nick_name can actually be computed:
      {
        'swimming_pool_name' => row.name,
        'city_id' => row.city_id,
        'pool_type_id' => row.pool_type_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'swimming_pool' => {
          'name' => row.name,
          'nick_name' => row.nick_name
        },
        'city_id' => row.city_id,
        'pool_type_id' => row.pool_type_id
      }
    },
    lambda { |row|
      {
        'swimming_pool' => { 'name' => row.name },
        'city_id' => row.city_id,
        'pool_type_id' => row.pool_type_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'swimming_pool' => {
          'name' => row.name,
          'nick_name' => row.nick_name
        },
        'city' => { 'id' => row.city_id },
        'pool_type' => { 'id' => row.pool_type_id }
      }
    },
    lambda { |row|
      {
        'swimming_pool' => { 'name' => row.name },
        'city' => { 'id' => row.city_id },
        'pool_type' => { 'id' => row.pool_type_id }
      }
    },
    lambda { |row|
      {
        'swimming_pool' => {
          'name' => row.name,
          'nick_name' => row.nick_name,
          'city' => { 'id' => row.city_id },
          'pool_type' => { 'id' => row.pool_type_id }
        }
      }
    },
    lambda { |row|
      {
        'swimming_pool' => {
          'name' => row.name,
          'city' => { 'id' => row.city_id },
          'pool_type' => { 'id' => row.pool_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index / 2}, var. #{index % 2})," do
      let(:fixture_row) { GogglesDb::SwimmingPool.first(50).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('SwimmingPool', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::SwimmingPool)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.name).to eq(fixture_row.name)
        end
        it 'has the expected nick_name' do
          expect(subject.entity.nick_name).to eq(fixture_row.nick_name)
        end
        it 'has the expected city_id' do
          expect(subject.entity.city_id).to eq(fixture_row.city_id)
        end
        it 'has the expected pool_type' do
          expect(subject.entity.pool_type_id).to eq(fixture_row.pool_type_id)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    #
    # VALID data: NEW row data
    #
    context "with solvable NEW #req data (valid @ depth #{index})," do
      let(:fixture_row) do
        new_row = FactoryBot.build(
          :swimming_pool,
          city: GogglesDb::City.first(100).sample,
          pool_type_id: [GogglesDb::PoolType::MT_25_ID, GogglesDb::PoolType::MT_25_ID].sample
        )
        # Use an actual pre-computed nick name based on the fixture values:
        # (so that it's predictable by the Solver class)
        new_row.nick_name = Solver::BaseStrategy.new.normalize_string_name_into_code(
          "#{new_row.city.name} #{new_row.name} #{new_row.pool_type.length_in_meters}"
        )
        expect(new_row.nick_name.length).to be <= 50
        new_row
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      subject do
        solver = Solver::Factory.for('SwimmingPool', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::SwimmingPool)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.name).to eq(fixture_row.name)
        end
        it 'has the expected nick_name' do
          expect(subject.entity.nick_name).to eq(fixture_row.nick_name)
        end
        it 'has the expected city_id' do
          expect(subject.entity.city_id).to eq(fixture_row.city_id)
        end
        it 'has the expected pool_type' do
          expect(subject.entity.pool_type_id).to eq(fixture_row.pool_type_id)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
