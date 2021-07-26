# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::MeetingSession, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'MeetingSession', Solver::MeetingSession)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'MeetingSession')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_session_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingSession')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting_session' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingSession')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_session_id' => row.id } },
    ->(row) { { 'meeting_session' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::MeetingSession.first(200).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingSession).and be_valid
        solver = Solver::Factory.for('MeetingSession', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingSession)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_id' => row.meeting_id,
        'session_order' => row.session_order,
        # Optional fields:
        'scheduled_date' => row.scheduled_date,
        'meeting_session_description' => row.description,
        'swimming_pool_id' => row.swimming_pool_id,
        'day_part_type_id' => row.day_part_type_id
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting_session' => {
          'meeting_id' => row.meeting_id,
          'session_order' => row.session_order,
          'scheduled_date' => row.scheduled_date,
          'description' => row.description
        },
        'swimming_pool_id' => row.swimming_pool_id,
        'day_part_type_id' => row.day_part_type_id
      }
    },
    lambda { |row|
      {
        'meeting_session' => {
          'meeting_id' => row.meeting_id,
          'session_order' => row.session_order,
          'scheduled_date' => row.scheduled_date,
          'description' => row.description,
          'swimming_pool_id' => row.swimming_pool_id,
          'day_part_type_id' => row.day_part_type_id
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting_session' => {
          'meeting_id' => row.meeting_id,
          'session_order' => row.session_order,
          'scheduled_date' => row.scheduled_date,
          'description' => row.description
        },
        'swimming_pool' => { 'id' => row.swimming_pool_id },
        'day_part_type' => { 'id' => row.day_part_type_id }
      }
    },
    lambda { |row|
      {
        'meeting_session' => {
          'meeting_id' => row.meeting_id,
          'session_order' => row.session_order,
          'scheduled_date' => row.scheduled_date,
          'description' => row.description,
          'swimming_pool' => { 'id' => row.swimming_pool_id },
          'day_part_type' => { 'id' => row.day_part_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      let(:fixture_row) { GogglesDb::MeetingSession.first(200).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingSession).and be_valid
        solver = Solver::Factory.for('MeetingSession', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingSession)

      describe '#entity' do
        %i[
          meeting_id session_order scheduled_date description
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
          :meeting_session,
          meeting_id: FactoryBot.create(:meeting).id,
          swimming_pool_id: FactoryBot.create(:swimming_pool).id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingSession).and be_valid
        solver = Solver::Factory.for('MeetingSession', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingSession)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_id session_order scheduled_date description swimming_pool_id
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
