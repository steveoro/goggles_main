# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Season, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'Season', Solver::Season)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'season_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Season')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'season' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Season')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'season_id' => row.id } },
    ->(row) { { 'season' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Season.first(50).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('Season', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Season)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'season_header_year' => row.header_year,
        'season_description' => row.description,
        'season_type_id' => row.season_type_id,
        # Ignored & not needed by finder, the following are creator's-only fields:
        'season_begin_date' => row.begin_date,
        'season_end_date' => row.end_date,
        'season_edition' => row.edition,
        'edition_type_id' => row.edition_type_id,
        'timing_type_id' => row.timing_type_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'season' => {
          'header_year' => row.header_year,
          'description' => row.description,
          'season_type_id' => row.season_type_id,
          # As above, creator's-only fields:
          'begin_date' => row.begin_date,
          'end_date' => row.end_date,
          'edition' => row.edition,
          'edition_type_id' => row.edition_type_id,
          'timing_type_id' => row.timing_type_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'season' => {
          'header_year' => row.header_year,
          'description' => row.description,
          'begin_date' => row.begin_date,
          'end_date' => row.end_date,
          'edition' => row.edition
        },
        'season_type' => { 'id' => row.season_type_id },
        'edition_type' => { 'id' => row.edition_type_id },
        'timing_type' => { 'id' => row.timing_type_id }
      }
    },
    lambda { |row|
      {
        'season' => {
          'header_year' => row.header_year,
          'description' => row.description,
          'season_type' => { 'id' => row.season_type_id },
          'begin_date' => row.begin_date,
          'end_date' => row.end_date,
          'edition' => row.edition,
          'edition_type' => { 'id' => row.edition_type_id },
          'timing_type' => { 'id' => row.timing_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Season.first(50).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('Season', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Season)

      describe '#entity' do
        it 'has the expected name' do
          expect(subject.entity.description).to eq(fixture_row.description)
        end
        it 'has the expected header_year' do
          expect(subject.entity.header_year).to eq(fixture_row.header_year)
        end
        it 'has the expected season_type_id' do
          expect(subject.entity.season_type_id).to eq(fixture_row.season_type_id)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    #
    # VALID data: NEW row data
    #
    context "with solvable NEW #req data (valid @ depth #{index})," do
      let(:fixture_row) { FactoryBot.build(:season) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        solver = Solver::Factory.for('Season', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Season)

      describe '#entity' do
        # Check all prepared fields:
        %w[
          description header_year begin_date end_date edition
          season_type_id edition_type_id timing_type_id
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
