# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::UserLap, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'UserLap', described_class)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'UserLap')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'user_lap_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'UserLap')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'user_lap' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'UserLap')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'user_lap_id' => row.id } },
    ->(row) { { 'user_lap' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserLap).and be_valid
        solver = Solver::Factory.for('UserLap', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { FactoryBot.create(:user_lap) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserLap)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'user_result_id' => row.user_result_id,
        'swimmer_id' => row.swimmer_id,
        'user_lap_length_in_meters' => row.length_in_meters,
        # Optional fields:
        'user_lap_reaction_time' => row.reaction_time,
        'user_lap_minutes' => row.minutes,
        'user_lap_seconds' => row.seconds,
        'user_lap_hundredths' => row.hundredths,
        'user_lap_position' => row.position,
        'minutes_from_start' => row.minutes_from_start,
        'seconds_from_start' => row.seconds_from_start,
        'hundredths_from_start' => row.hundredths_from_start
      }
    },
    # depth 1
    lambda { |row|
      {
        'user_lap' => {
          'user_result_id' => row.user_result_id,
          'swimmer_id' => row.swimmer_id,
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
        'user_lap' => {
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
        'user_result_id' => row.user_result_id,
        'swimmer_id' => row.swimmer_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'user_lap' => {
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
        'user_result' => { 'id' => row.user_result_id },
        'swimmer' => { 'id' => row.swimmer_id }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserLap).and be_valid
        solver = Solver::Factory.for('UserLap', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { FactoryBot.create(:user_lap) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserLap)

      describe '#entity' do
        %i[
          user_result_id swimmer_id
          reaction_time minutes seconds hundredths length_in_meters position
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
        solver = Solver::Factory.for('UserLap', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        FactoryBot.build(
          :user_lap,
          user_result: FactoryBot.create(:user_result, event_date: Time.zone.today),
          swimmer_id: GogglesDb::Swimmer.first(150).sample.id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserLap)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          user_result_id swimmer_id
          reaction_time minutes seconds hundredths length_in_meters position
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
