# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Meeting, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'Meeting', Solver::Meeting)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Meeting')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Meeting')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_id' => row.id } },
    ->(row) { { 'meeting' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Meeting.first(200).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
        solver = Solver::Factory.for('Meeting', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Meeting)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_description' => row.description,
        'season_id' => row.season_id,
        'header_date' => row.header_date,
        # Optional fields:
        'team_id' => row.home_team_id,
        'edition' => row.edition,
        'edition_type_id' => row.edition_type_id,
        'timing_type_id' => row.timing_type_id,
        'header_year' => row.header_year,
        'meeting_code' => row.code
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code,
          'edition' => row.edition
        },
        'team_id' => row.home_team_id,
        'season_id' => row.season_id,
        'edition_type_id' => row.edition_type_id,
        'timing_type_id' => row.timing_type_id
      }
    },
    lambda { |row|
      {
        'meeting' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code,
          'team_id' => row.home_team_id,
          'season_id' => row.season_id,
          'edition_type_id' => row.edition_type_id,
          'timing_type_id' => row.timing_type_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code
        },
        'team' => { 'id' => row.home_team_id },
        'season' => { 'id' => row.season_id },
        'edition_type' => { 'id' => row.edition_type_id },
        'timing_type' => { 'id' => row.timing_type_id }
      }
    },
    lambda { |row|
      {
        'meeting' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code,
          'team' => { 'id' => row.home_team_id },
          'season' => { 'id' => row.season_id },
          'edition_type' => { 'id' => row.edition_type_id },
          'timing_type' => { 'id' => row.timing_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      let(:fixture_row) { GogglesDb::Meeting.first(200).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
        solver = Solver::Factory.for('Meeting', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Meeting)

      describe '#entity' do
        %i[
          description season_id header_date
        ].each do |column_name|
          it "has the expected #{column_name}" do
            expect(subject.entity.send(column_name)).to eq(fixture_row.send(column_name))
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    #
    # VALID data: NEW row data
    #
    context "with solvable NEW #req data (valid w/ layout #{index})," do
      let(:fixture_row) do
        FactoryBot.build(
          :meeting,
          home_team_id: GogglesDb::Team.first(100).sample.id,
          season_id: GogglesDb::Season.last(10).sample.id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
        solver = Solver::Factory.for('Meeting', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Meeting)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          description home_team_id season_id header_date
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
