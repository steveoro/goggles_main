# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::MeetingEvent, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'MeetingEvent', described_class)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'MeetingEvent')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_event_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingEvent')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting_event' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingEvent')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_event_id' => row.id } },
    ->(row) { { 'meeting_event' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingEvent).and be_valid
        solver = Solver::Factory.for('MeetingEvent', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::MeetingEvent.first(200).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingEvent)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_session_id' => row.meeting_session_id,
        'event_type_id' => row.event_type_id,
        # Optional fields:
        'heat_type_id' => row.heat_type_id,
        'event_order' => row.event_order,
        'begin_time' => row.begin_time
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting_event' => {
          'meeting_session_id' => row.meeting_session_id,
          'event_type_id' => row.event_type_id,
          'heat_type_id' => row.heat_type_id,
          'event_order' => row.event_order,
          'begin_time' => row.begin_time
        }
      }
    },
    lambda { |row|
      {
        'meeting_event' => {
          'event_order' => row.event_order,
          'begin_time' => row.begin_time
        },
        'meeting_session_id' => row.meeting_session_id,
        'event_type_id' => row.event_type_id,
        'heat_type_id' => row.heat_type_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting_event' => {
          'event_order' => row.event_order,
          'begin_time' => row.begin_time
        },
        'meeting_session' => { 'id' => row.meeting_session_id },
        'event_type' => { 'id' => row.event_type_id },
        'heat_type' => { 'id' => row.heat_type_id }
      }
    },
    lambda { |row|
      {
        'meeting_event' => {
          'event_order' => row.event_order,
          'begin_time' => row.begin_time,
          'meeting_session' => { 'id' => row.meeting_session_id },
          'event_type' => { 'id' => row.event_type_id },
          'heat_type' => { 'id' => row.heat_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingEvent).and be_valid
        solver = Solver::Factory.for('MeetingEvent', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::MeetingEvent.first(300).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingEvent)

      describe '#entity' do
        %i[
          meeting_session_id event_type_id heat_type_id event_order begin_time
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
        expect(fixture_row).to be_a(GogglesDb::MeetingEvent).and be_valid
        solver = Solver::Factory.for('MeetingEvent', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        msession = FactoryBot.create(:meeting_session)
        FactoryBot.build(
          :meeting_event,
          meeting_session_id: msession.id,
          event_type_id: GogglesDb::EventsByPoolType.eventable
                                                    .for_pool_type(msession.pool_type)
                                                    .sample
                                                    .event_type_id,
          heat_type_id: GogglesDb::HeatType::FINALS_ID,
          begin_time: DateTime.now.in_time_zone('Europe/Rome').to_s
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingEvent)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_session_id event_type_id heat_type_id event_order begin_time
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
