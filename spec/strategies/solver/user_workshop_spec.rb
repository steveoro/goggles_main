# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::UserWorkshop, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'UserWorkshop', Solver::UserWorkshop)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'user_workshop_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'UserWorkshop')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'user_workshop' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'UserWorkshop')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'user_workshop_id' => row.id } },
    ->(row) { { 'user_workshop' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { FactoryBot.create(:user_workshop) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserWorkshop).and be_valid
        solver = Solver::Factory.for('UserWorkshop', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserWorkshop)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'user_workshop_description' => row.description,
        'user_workshop_user_id' => row.user_id,
        'team_id' => row.team_id,
        'season_id' => row.season_id,
        'header_date' => row.header_date,
        # Optional fields:
        'edition' => row.edition,
        'edition_type_id' => row.edition_type_id,
        'timing_type_id' => row.timing_type_id,
        'header_year' => row.header_year,
        'user_workshop_code' => row.code,
        'swimming_pool_id' => row.swimming_pool_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'user_workshop' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code,
          'edition' => row.edition
        },
        'user_workshop_user_id' => row.user_id,
        'team_id' => row.team_id,
        'season_id' => row.season_id,
        'edition_type_id' => row.edition_type_id,
        'timing_type_id' => row.timing_type_id,
        'swimming_pool_id' => row.swimming_pool_id
      }
    },
    lambda { |row|
      {
        'user_workshop' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code,
          'user_id' => row.user_id,
          'team_id' => row.team_id,
          'season_id' => row.season_id,
          'edition_type_id' => row.edition_type_id,
          'timing_type_id' => row.timing_type_id,
          'swimming_pool_id' => row.swimming_pool_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'user_workshop' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code
        },
        'user_workshop_user_id' => row.user_id, # This can't ever be nested (must be a given value)
        'team' => { 'id' => row.team_id },
        'season' => { 'id' => row.season_id },
        'edition_type' => { 'id' => row.edition_type_id },
        'timing_type' => { 'id' => row.timing_type_id },
        'swimming_pool' => { 'id' => row.swimming_pool_id }
      }
    },
    lambda { |row|
      {
        'user_workshop' => {
          'description' => row.description,
          'header_date' => row.header_date,
          'header_year' => row.header_year,
          'code' => row.code,
          'user_id' => row.user_id, # This can't ever be nested (must be a given value)
          'team' => { 'id' => row.team_id },
          'season' => { 'id' => row.season_id },
          'edition_type' => { 'id' => row.edition_type_id },
          'timing_type' => { 'id' => row.timing_type_id },
          'swimming_pool' => { 'id' => row.swimming_pool_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      let(:fixture_row) { FactoryBot.create(:user_workshop) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserWorkshop).and be_valid
        solver = Solver::Factory.for('UserWorkshop', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserWorkshop)

      describe '#entity' do
        %i[
          description user_id team_id season_id header_date
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
          :user_workshop,
          user_id: GogglesDb::User.first(100).sample.id,
          team_id: GogglesDb::Team.first(100).sample.id,
          season_id: GogglesDb::Season.last(10).sample.id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserWorkshop).and be_valid
        solver = Solver::Factory.for('UserWorkshop', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserWorkshop)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          description user_id team_id season_id header_date
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
