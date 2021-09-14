# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::MeetingIndividualResult, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like(
      'Solver strategy, bindings, finder & creator, before #solve!',
      'MeetingIndividualResult', described_class
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'MeetingIndividualResult')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_individual_result_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingIndividualResult')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting_individual_result' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingIndividualResult')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_individual_result_id' => row.id } },
    ->(row) { { 'meeting_individual_result' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        solver = Solver::Factory.for('MeetingIndividualResult', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::MeetingIndividualResult.first(100).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingIndividualResult)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_program_id' => row.meeting_program_id,
        'swimmer_id' => row.swimmer_id,
        'team_id' => row.team_id,
        'team_affiliation_id' => row.team_affiliation_id,
        'badge_id' => row.badge_id,
        'meeting_individual_result_rank' => row.rank,
        'meeting_individual_result_reaction_time' => row.reaction_time,
        'meeting_individual_result_minutes' => row.minutes,
        'meeting_individual_result_seconds' => row.seconds,
        'meeting_individual_result_hundredths' => row.hundredths,
        'meeting_individual_result_standard_points' => row.standard_points,
        'meeting_individual_result_meeting_points' => row.meeting_points
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting_individual_result' => {
          'meeting_program_id' => row.meeting_program_id,
          'swimmer_id' => row.swimmer_id,
          'team_id' => row.team_id,
          'team_affiliation_id' => row.team_affiliation_id,
          'badge_id' => row.badge_id,
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
        'meeting_individual_result' => {
          'rank' => row.rank,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'standard_points' => row.standard_points,
          'meeting_points' => row.meeting_points
        },
        'meeting_program_id' => row.meeting_program_id,
        'swimmer_id' => row.swimmer_id,
        'team_id' => row.team_id,
        'team_affiliation_id' => row.team_affiliation_id,
        'badge_id' => row.badge_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting_individual_result' => {
          'rank' => row.rank,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths,
          'standard_points' => row.standard_points,
          'meeting_points' => row.meeting_points
        },
        'meeting_program' => { 'id' => row.meeting_program_id },
        'swimmer' => { 'id' => row.swimmer_id },
        'team' => { 'id' => row.team_id },
        'team_affiliation' => { 'id' => row.team_affiliation_id },
        'badge' => { 'id' => row.badge_id }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
        solver = Solver::Factory.for('MeetingIndividualResult', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { FactoryBot.create(:meeting_individual_result) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingIndividualResult)

      describe '#entity' do
        %i[
          meeting_program_id swimmer_id team_id
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
        expect(fixture_row).to be_a(GogglesDb::MeetingIndividualResult).and be_valid
        solver = Solver::Factory.for('MeetingIndividualResult', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        badge = FactoryBot.create(:badge)
        FactoryBot.build(
          :meeting_individual_result,
          badge_id: badge.id,
          swimmer_id: badge.swimmer_id,
          team_id: badge.team_id,
          team_affiliation_id: badge.team_affiliation_id,
          meeting_program_id: FactoryBot.create(:meeting_program_individual).id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingIndividualResult)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_program_id swimmer_id team_id
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
