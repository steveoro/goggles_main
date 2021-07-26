# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::TeamAffiliation, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'TeamAffiliation', Solver::TeamAffiliation)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'TeamAffiliation')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'team_affiliation_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'TeamAffiliation')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'team_affiliation' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'TeamAffiliation')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'team_affiliation_id' => row.id } },
    ->(row) { { 'team_affiliation' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::TeamAffiliation.first(150).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('TeamAffiliation', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::TeamAffiliation)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'team_affiliation_name' => row.name,
        'team_affiliation_number' => row.number, # (Optional)
        'team_id' => row.team_id,
        'season_id' => row.season_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'team_affiliation' => {
          'name' => row.name,
          'number' => row.number, # (Optional)
          'team_id' => row.team_id,
          'season_id' => row.season_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'team_affiliation' => {
          'name' => row.name,
          'number' => row.number # (Optional)
        },
        'team' => { 'id' => row.team_id },
        'season' => { 'id' => row.season_id }
      }
    },
    lambda { |row|
      {
        'team_affiliation' => {
          'name' => row.name,
          'number' => row.number, # (Optional)
          'team' => { 'id' => row.team_id },
          'season' => { 'id' => row.season_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::TeamAffiliation.first(150).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('TeamAffiliation', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::TeamAffiliation)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.name).to eq(fixture_row.name)
        end
        it 'has the expected team_id' do
          expect(subject.entity.team_id).to eq(fixture_row.team_id)
        end
        it 'has the expected season_id' do
          expect(subject.entity.season_id).to eq(fixture_row.season_id)
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
        FactoryBot.build(
          :team_affiliation,
          team_id: GogglesDb::Team.first(100).sample.id,
          season_id: GogglesDb::Season.last(10).sample.id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false } # (disable ID check)
      subject do
        solver = Solver::Factory.for('TeamAffiliation', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::TeamAffiliation)

      describe '#entity' do
        # Check all prepared fields:
        %w[
          name number team_id season_id
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
