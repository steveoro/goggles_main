# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Lap, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like(
      'Solver strategy, bindings, finder & creator, before #solve!',
      'Lap', described_class
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'Lap')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'lap_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Lap')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'lap' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Lap')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'lap_id' => row.id } },
    ->(row) { { 'lap' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        solver = Solver::Factory.for('Lap', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::Lap.first(300).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Lap)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_individual_result_id' => row.meeting_individual_result_id,
        'meeting_program_id' => row.meeting_program_id,
        'swimmer_id' => row.swimmer_id,
        'team_id' => row.team_id,
        'lap_length_in_meters' => row.length_in_meters,
        # Optional fields:
        'lap_reaction_time' => row.reaction_time,
        'lap_minutes' => row.minutes,
        'lap_seconds' => row.seconds,
        'lap_hundredths' => row.hundredths,
        'lap_position' => row.position,
        'minutes_from_start' => row.minutes_from_start,
        'seconds_from_start' => row.seconds_from_start,
        'hundredths_from_start' => row.hundredths_from_start
      }
    },
    # depth 1
    lambda { |row|
      {
        'lap' => {
          'meeting_individual_result_id' => row.meeting_individual_result_id,
          'meeting_program_id' => row.meeting_program_id,
          'swimmer_id' => row.swimmer_id,
          'team_id' => row.team_id,
          'length_in_meters' => row.length_in_meters,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'position' => row.position,
          'minutes_from_start' => row.minutes_from_start,
          'seconds_from_start' => row.seconds_from_start,
          'hundredths_from_start' => row.hundredths_from_start
        }
      }
    },
    lambda { |row|
      {
        'lap' => {
          'length_in_meters' => row.length_in_meters,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'position' => row.position,
          'minutes_from_start' => row.minutes_from_start,
          'seconds_from_start' => row.seconds_from_start,
          'hundredths_from_start' => row.hundredths_from_start
        },
        'meeting_individual_result_id' => row.meeting_individual_result_id,
        'meeting_program_id' => row.meeting_program_id,
        'swimmer_id' => row.swimmer_id,
        'team_id' => row.team_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'lap' => {
          'length_in_meters' => row.length_in_meters,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'position' => row.position,
          'minutes_from_start' => row.minutes_from_start,
          'seconds_from_start' => row.seconds_from_start,
          'hundredths_from_start' => row.hundredths_from_start
        },
        'meeting_individual_result' => { 'id' => row.meeting_individual_result_id },
        'meeting_program' => { 'id' => row.meeting_program_id },
        'swimmer' => { 'id' => row.swimmer_id },
        'team' => { 'id' => row.team_id }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::Lap).and be_valid
        solver = Solver::Factory.for('Lap', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::Lap.first(300).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Lap)

      describe '#entity' do
        %i[
          meeting_individual_result_id meeting_program_id swimmer_id team_id length_in_meters
          reaction_time minutes seconds hundredths position
          minutes_from_start seconds_from_start hundredths_from_start
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
      subject do
        expect(fixture_row).to be_a(GogglesDb::Lap).and be_valid
        solver = Solver::Factory.for('Lap', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        mir = FactoryBot.create(:meeting_individual_result)
        FactoryBot.build(
          :lap,
          meeting_individual_result_id: mir.id,
          meeting_program_id: mir.meeting_program_id,
          swimmer_id: mir.swimmer_id,
          team_id: mir.team_id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::Lap)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_individual_result_id meeting_program_id swimmer_id team_id length_in_meters
          reaction_time minutes seconds hundredths position
          minutes_from_start seconds_from_start hundredths_from_start
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
