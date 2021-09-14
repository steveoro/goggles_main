# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::MeetingProgram, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'MeetingProgram', described_class)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }

    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'MeetingProgram')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'meeting_program_id' => -1 } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingProgram')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'meeting_program' => { 'id' => -1 } } }

    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'MeetingProgram')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'meeting_program_id' => row.id } },
    ->(row) { { 'meeting_program' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingProgram).and be_valid
        solver = Solver::Factory.for('MeetingProgram', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::MeetingProgram.first(200).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingProgram)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'meeting_event_id' => row.meeting_event_id,
        'pool_type_id' => row.pool_type_id,
        'category_type_id' => row.category_type_id,
        'gender_type_id' => row.gender_type_id,
        # Optional fields:
        'event_order' => row.event_order,
        'begin_time' => row.begin_time
      }
    },
    # depth 1
    lambda { |row|
      {
        'meeting_program' => {
          'meeting_event_id' => row.meeting_event_id,
          'category_type_id' => row.category_type_id,
          'gender_type_id' => row.gender_type_id,
          'event_order' => row.event_order,
          'begin_time' => row.begin_time,
          'pool_type_id' => row.pool_type_id
        }
      }
    },
    lambda { |row|
      {
        'meeting_program' => {
          'event_order' => row.event_order,
          'begin_time' => row.begin_time
        },
        'meeting_event_id' => row.meeting_event_id,
        'pool_type_id' => row.pool_type_id,
        'category_type_id' => row.category_type_id,
        'gender_type_id' => row.gender_type_id
      }
    },
    lambda { |row|
      {
        'meeting_program' => {
          'event_order' => row.event_order,
          'begin_time' => row.begin_time
        },
        'meeting_event' => { 'id' => row.meeting_event_id },
        'pool_type' => { 'id' => row.pool_type_id },
        'category_type' => { 'id' => row.category_type_id },
        'gender_type' => { 'id' => row.gender_type_id }
      }
    },
    # depth 2
    lambda { |row|
      {
        'meeting_program' => {
          'event_order' => row.event_order,
          'begin_time' => row.begin_time,
          'meeting_event' => { 'id' => row.meeting_event_id },
          'category_type' => { 'id' => row.category_type_id },
          'gender_type' => { 'id' => row.gender_type_id },
          'pool_type' => { 'id' => row.pool_type_id }
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      subject do
        expect(fixture_row).to be_a(GogglesDb::MeetingProgram).and be_valid
        solver = Solver::Factory.for('MeetingProgram', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) { GogglesDb::MeetingProgram.first(300).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingProgram)

      describe '#entity' do
        %i[
          meeting_event_id pool_type_id category_type_id gender_type_id
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
        expect(fixture_row).to be_a(GogglesDb::MeetingProgram).and be_valid
        solver = Solver::Factory.for('MeetingProgram', fixture_req)
        solver.solve!
        solver
      end

      let(:fixture_row) do
        mevent = FactoryBot.create(:meeting_event_individual)
        FactoryBot.build(
          :meeting_program,
          pool_type_id: mevent.meeting_session.swimming_pool.pool_type_id,
          category_type_id: GogglesDb::CategoryType.eventable.individuals.sample.id,
          gender_type_id: [GogglesDb::GenderType::MALE_ID, GogglesDb::GenderType::FEMALE_ID].sample
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }

      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::MeetingProgram)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          meeting_event_id pool_type_id category_type_id gender_type_id
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
