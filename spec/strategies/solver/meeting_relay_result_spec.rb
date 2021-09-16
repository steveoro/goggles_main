# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::MeetingRelayResult, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like(
      'Solver strategy, bindings, finder & creator, before #solve!',
      'MeetingRelayResult', described_class
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'MeetingRelayResult')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_relay_result_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingRelayResult')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting_relay_result' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingRelayResult')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_relay_result_id' => row.id } },
    ->(row) { { 'meeting_relay_result' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingRelayResult).and be_valid
        solver = Solver::Factory.for('MeetingRelayResult', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        # Choose valid domain data only (TODO: data fix is required)
        GogglesDb::MeetingRelayResult.where("relay_code != ''")
                                     .where.not(team_affiliation_id: nil)
                                     .first(200).sample
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingRelayResult)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_program_id' => row.meeting_program_id,
        'team_id' => row.team_id,
        'team_affiliation_id' => row.team_affiliation_id,
        'relay_code' => row.relay_code,
        'meeting_relay_result_rank' => row.rank,
        'meeting_relay_result_reaction_time' => row.reaction_time,
        'meeting_relay_result_minutes' => row.minutes,
        'meeting_relay_result_seconds' => row.seconds,
        'meeting_relay_result_hundredths' => row.hundredths,
        'meeting_relay_result_standard_points' => row.standard_points,
        'meeting_relay_result_meeting_points' => row.meeting_points
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting_relay_result' => {
          'meeting_program_id' => row.meeting_program_id,
          'team_id' => row.team_id,
          'team_affiliation_id' => row.team_affiliation_id,
          'relay_code' => row.relay_code,
          'rank' => row.rank,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'standard_points' => row.standard_points,
          'meeting_points' => row.meeting_points
        }
      }
    },
    lambda { |row|
      {
        'meeting_relay_result' => {
          'relay_code' => row.relay_code,
          'rank' => row.rank,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'standard_points' => row.standard_points,
          'meeting_points' => row.meeting_points
        },
        'meeting_program_id' => row.meeting_program_id,
        'team_id' => row.team_id,
        'team_affiliation_id' => row.team_affiliation_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting_relay_result' => {
          'relay_code' => row.relay_code,
          'rank' => row.rank,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'standard_points' => row.standard_points,
          'meeting_points' => row.meeting_points
        },
        'meeting_program' => { 'id' => row.meeting_program_id },
        'team' => { 'id' => row.team_id },
        'team_affiliation' => { 'id' => row.team_affiliation_id }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingRelayResult).and be_valid
        solver = Solver::Factory.for('MeetingRelayResult', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        # Choose valid domain data only:
        GogglesDb::MeetingRelayResult.where("relay_code != ''")
                                     .first(200).sample
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingRelayResult)

      describe '#entity' do
        %i[
          meeting_program_id team_affiliation_id team_id
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
        expect(fixture_row).to be_a(GogglesDb::MeetingRelayResult).and be_valid
        solver = Solver::Factory.for('MeetingRelayResult', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        badge = FactoryBot.create(:badge)
        FactoryBot.build(
          :meeting_relay_result,
          team_id: badge.team_id,
          team_affiliation_id: badge.team_affiliation_id,
          meeting_program_id: FactoryBot.create(:meeting_program_relay).id,
          entry_time_type_id: GogglesDb::EntryTimeType::LAST_RACE_ID
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingRelayResult)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_program_id team_affiliation_id team_id
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
