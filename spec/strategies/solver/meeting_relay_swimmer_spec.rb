# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::MeetingRelaySwimmer, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like(
      'Solver strategy, bindings, finder & creator, before #solve!',
      'MeetingRelaySwimmer', Solver::MeetingRelaySwimmer
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'MeetingRelaySwimmer')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_relay_swimmer_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingRelaySwimmer')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting_relay_swimmer' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingRelaySwimmer')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_relay_swimmer_id' => row.id } },
    ->(row) { { 'meeting_relay_swimmer' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::MeetingRelaySwimmer.first(300).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
        solver = Solver::Factory.for('MeetingRelaySwimmer', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingRelaySwimmer)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_relay_result_id' => row.meeting_relay_result_id,
        'stroke_type_id' => row.stroke_type_id,
        'swimmer_id' => row.swimmer_id,
        'badge_id' => row.badge_id,
        # Optional fields:
        'relay_order' => row.relay_order,
        'meeting_relay_swimmer_reaction_time' => row.reaction_time,
        'meeting_relay_swimmer_minutes' => row.minutes,
        'meeting_relay_swimmer_seconds' => row.seconds,
        'meeting_relay_swimmer_hundredths' => row.hundredths
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting_relay_swimmer' => {
          'meeting_relay_result_id' => row.meeting_relay_result_id,
          'stroke_type_id' => row.stroke_type_id,
          'swimmer_id' => row.swimmer_id,
          'badge_id' => row.badge_id,
          'relay_order' => row.relay_order,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths
        }
      }
    },
    lambda { |row|
      {
        'meeting_relay_swimmer' => {
          'relay_order' => row.relay_order,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths
        },
        'meeting_relay_result_id' => row.meeting_relay_result_id,
        'stroke_type_id' => row.stroke_type_id,
        'swimmer_id' => row.swimmer_id,
        'badge_id' => row.badge_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting_relay_swimmer' => {
          'relay_order' => row.relay_order,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths
        },
        'meeting_relay_result' => { 'id' => row.meeting_relay_result_id },
        'stroke_type' => { 'id' => row.stroke_type_id },
        'swimmer' => { 'id' => row.swimmer_id },
        'badge' => { 'id' => row.badge_id }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      let(:fixture_row) { GogglesDb::MeetingRelaySwimmer.first(300).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
        solver = Solver::Factory.for('MeetingRelaySwimmer', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingRelaySwimmer)

      describe '#entity' do
        %i[
          meeting_relay_result_id stroke_type_id swimmer_id badge_id
          relay_order reaction_time minutes seconds hundredths
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
        mrr = FactoryBot.create(:meeting_relay_result)
        badge = GogglesDb::Badge.last(300).sample
        FactoryBot.build(
          :meeting_relay_swimmer,
          meeting_relay_result_id: mrr.id,
          stroke_type_id: [1, 2, 3, 4].sample,
          swimmer_id: badge.swimmer_id,
          badge_id: badge.id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
        solver = Solver::Factory.for('MeetingRelaySwimmer', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingRelaySwimmer)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_relay_result_id stroke_type_id swimmer_id badge_id
          relay_order reaction_time minutes seconds hundredths
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
