# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Team, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'Team', described_class)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'Team')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'team_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Team')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'team' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Team')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'team_id' => row.id } },
    ->(row) { { 'team' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        solver = Solver::Factory.for('Team', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::Team.first(100).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Team)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'team_name' => row.name,
        'city_id' => row.city_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'team' => {
          'name' => row.name
        },
        'city_id' => row.city_id
      }
    },
    lambda { |row|
      {
        'team' => {
          'name' => row.name,
          'city_id' => row.city_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'team' => {
          'name' => row.name
        },
        'city' => { 'id' => row.city_id }
      }
    },
    lambda { |row|
      {
        'team' => {
          'name' => row.name,
          'city' => { 'id' => row.city_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        solver = Solver::Factory.for('Team', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::Team.first(100).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Team)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.name).to eq(fixture_row.name)
        end

        it 'has the expected city_id' do
          expect(subject.entity.city_id).to eq(fixture_row.city_id)
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
        solver = Solver::Factory.for('Team', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { FactoryBot.build(:team, name: "NON-EXISTING A.S.D. #{(rand * 10_000).to_i}") }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Team)

      describe '#entity' do
        # Check all prepared fields (more than the actual bindings):
        %w[
          name editable_name city_id
        ].each do |column_name|
          it "has the expected #{column_name}" do
            expect(subject.entity.send(column_name)).to eq(fixture_row.send(column_name))
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
