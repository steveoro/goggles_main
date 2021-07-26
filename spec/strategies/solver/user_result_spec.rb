# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::UserResult, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'UserResult', Solver::UserResult)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'UserResult')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'user_result_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'UserResult')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'user_result' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'UserResult')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'user_result_id' => row.id } },
    ->(row) { { 'user_result' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { FactoryBot.create(:user_result) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserResult).and be_valid
        solver = Solver::Factory.for('UserResult', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserResult)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'user_workshop_id' => row.user_workshop_id,
        'user_result_user_id' => row.user_id,
        'swimmer_id' => row.swimmer_id,
        'category_type_id' => row.category_type_id,
        'pool_type_id' => row.pool_type_id,
        'event_type_id' => row.event_type_id,
        'event_date' => row.event_date,
        'swimming_pool_id' => row.swimming_pool_id,
        'user_result_reaction_time' => row.reaction_time,
        'user_result_minutes' => row.minutes,
        'user_result_seconds' => row.seconds,
        'user_result_hundredths' => row.hundredths
      }
    },
    # depth 1
    lambda { |row|
      {
        'user_result' => {
          'user_workshop_id' => row.user_workshop_id,
          'user_id' => row.user_id,
          'swimmer_id' => row.swimmer_id,
          'category_type_id' => row.category_type_id,
          'pool_type_id' => row.pool_type_id,
          'event_type_id' => row.event_type_id,
          'event_date' => row.event_date,
          'swimming_pool_id' => row.swimming_pool_id,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths
        }
      }
    },
    lambda { |row|
      {
        'user_result' => {
          'event_date' => row.event_date,
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths
        },
        'user_workshop_id' => row.user_workshop_id,
        'user_result_user_id' => row.user_id,
        'swimmer_id' => row.swimmer_id,
        'category_type_id' => row.category_type_id,
        'pool_type_id' => row.pool_type_id,
        'event_type_id' => row.event_type_id,
        'swimming_pool_id' => row.swimming_pool_id
      }
    },
    # depth 2
    lambda { |row|
      {
        'user_result' => {
          'user_workshop' => { 'id' => row.user_workshop_id },
          'user_id' => row.user_id,
          'swimmer' => { 'id' => row.swimmer_id },
          'category_type' => { 'id' => row.category_type_id },
          'pool_type' => { 'id' => row.pool_type_id },
          'event_type' => { 'id' => row.event_type_id },
          'event_date' => row.event_date,
          'swimming_pool' => { 'id' => row.swimming_pool_id },
          'reaction_time' => row.reaction_time,
          'minutes' => row.minutes,
          'seconds' => row.seconds,
          'hundredths' => row.hundredths
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid w/ layout #{index})," do
      let(:fixture_row) { FactoryBot.create(:user_result) }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      before(:each) do
        expect(fixture_row).to be_a(GogglesDb::UserResult).and be_valid
      end
      subject do
        solver = Solver::Factory.for('UserResult', fixture_req)
        solver.solve!
        expect(solver).to be_solved
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserResult)

      describe '#entity' do
        %i[
          user_workshop_id user_id swimmer_id category_type_id pool_type_id swimming_pool_id
          event_type_id event_date minutes seconds hundredths reaction_time
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
          :user_result,
          user_workshop_id: FactoryBot.create(:user_workshop).id,
          user_id: GogglesDb::User.first(100).sample.id,
          swimmer_id: GogglesDb::Swimmer.first(150).sample.id,
          pool_type_id: GogglesDb::PoolType.all_eventable.sample.id,
          swimming_pool_id: GogglesDb::SwimmingPool.first(100).sample.id,
          category_type_id: GogglesDb::CategoryType.eventable.individuals.sample.id,
          event_type_id: GogglesDb::EventsByPoolType.eventable.individuals.sample.event_type_id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false }
      subject do
        expect(fixture_row).to be_a(GogglesDb::UserResult).and be_valid
        solver = Solver::Factory.for('UserResult', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserResult)

      describe '#entity' do
        # Check all prepared fields:
        %i[
          user_workshop_id user_id swimmer_id category_type_id pool_type_id swimming_pool_id
          event_type_id event_date minutes seconds hundredths reaction_time
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
