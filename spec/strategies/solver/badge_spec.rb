# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Badge, type: :strategy do
  context 'before #solve!,' do
    it_behaves_like('Solver strategy, bindings, finder & creator, before #solve!', 'Badge', Solver::Badge)
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INVALID data: empty request
  #
  context 'with EMPTY #req data,' do
    let(:fixture_req) { {} }
    it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', 'Badge')
  end

  #
  # INVALID data: BAD ID, @ root
  #
  context 'with INVALID #req data (non-existing id @ root lv.),' do
    let(:fixture_req) { { 'badge_id' => -1 } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Badge')
  end

  #
  # INVALID data: BAD ID, @ sub-entity
  #
  context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
    let(:fixture_req) { { 'badge' => { 'id' => -1 } } }
    it_behaves_like('Solver strategy, bindings, UNSOLVABLE req, after #solve!', 'Badge')
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    ->(row) { { 'badge_id' => row.id } },
    ->(row) { { 'badge' => { 'id' => row.id } } }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING ID
    #
    context "with valid & solved #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Badge.first(150).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        solver = Solver::Factory.for('Badge', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Badge)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [
    # depth 0
    lambda { |row|
      {
        'category_type_id' => row.category_type_id,
        'team_affiliation_id' => row.team_affiliation_id,
        'team_id' => row.team_id,
        'swimmer_id' => row.swimmer_id,
        'season_id' => row.season_id,
        # Optionals:
        'entry_time_type_id' => row.entry_time_type_id,
        'badge_number' => row.number,
        'badge_off_gogglecup' => row.off_gogglecup,
        'badge_fees_due' => row.fees_due,
        'badge_badge_due' => row.badge_due,
        'badge_relays_due' => row.relays_due
      }
    },
    # depth 1
    lambda { |row|
      {
        'badge' => {
          'category_type_id' => row.category_type_id,
          'team_affiliation_id' => row.team_affiliation_id,
          'team_id' => row.team_id,
          'swimmer_id' => row.swimmer_id,
          'season_id' => row.season_id,
          'entry_time_type_id' => row.entry_time_type_id,
          'number' => row.number,
          'off_gogglecup' => row.off_gogglecup,
          'fees_due' => row.fees_due,
          'badge_due' => row.badge_due,
          'relays_due' => row.relays_due
        }
      }
    },
    # depth 2
    lambda { |row|
      {
        'badge' => {
          'category_type' => { 'id' => row.category_type_id },
          'team_affiliation' => { 'id' => row.team_affiliation_id },
          'team' => { 'id' => row.team_id },
          'swimmer' => { 'id' => row.swimmer_id },
          'season' => { 'id' => row.season_id },
          'entry_time_type' => { 'id' => row.entry_time_type_id },
          'number' => row.number,
          'off_gogglecup' => row.off_gogglecup,
          'fees_due' => row.fees_due,
          'badge_due' => row.badge_due,
          'relays_due' => row.relays_due
        }
      }
    }
  ].each_with_index do |req, index|
    #
    # VALID data: EXISTING row data
    #
    context "with solvable #req data (valid @ depth #{index})," do
      let(:fixture_row) { GogglesDb::Badge.first(150).sample }
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { fixture_row.id }
      subject do
        expect(fixture_row).to be_a(GogglesDb::Badge).and be_valid
        solver = Solver::Factory.for('Badge', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Badge)

      describe '#entity' do
        it 'has the expected category_type_id' do
          expect(subject.entity.category_type_id).to eq(fixture_row.category_type_id)
        end
        it 'has the expected team_affiliation_id' do
          expect(subject.entity.team_affiliation_id).to eq(fixture_row.team_affiliation_id)
        end
        it 'has the expected team_id' do
          expect(subject.entity.team_id).to eq(fixture_row.team_id)
        end
        it 'has the expected swimmer_id' do
          expect(subject.entity.swimmer_id).to eq(fixture_row.swimmer_id)
        end
        it 'has the expected season_id' do
          expect(subject.entity.season_id).to eq(fixture_row.season_id)
        end
        it 'has the expected entry_time_type_id' do
          expect(subject.entity.entry_time_type_id).to eq(fixture_row.entry_time_type_id)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    #
    # VALID data: NEW row data
    #
    context "with solvable NEW #req data (valid @ depth #{index})," do
      let(:fixture_row) do
        FactoryBot.build(
          :badge,
          category_type_id: GogglesDb::CategoryType.first(150).sample.id,
          team_affiliation_id: GogglesDb::TeamAffiliation.first(150).sample.id,
          team_id: GogglesDb::Team.first(150).sample.id,
          swimmer_id: GogglesDb::Swimmer.first(150).sample.id,
          season_id: GogglesDb::Season.last(50).sample.id
        )
      end
      let(:fixture_req) { req.call(fixture_row) }
      let(:expected_id) { false } # (disable ID check)
      subject do
        expect(fixture_row).to be_a(GogglesDb::Badge).and be_valid
        solver = Solver::Factory.for('Badge', fixture_req)
        solver.solve!
        solver
      end
      it_behaves_like('Solver strategy, bindings, solvable req, after #solve!', GogglesDb::Badge)

      describe '#entity' do
        # Check all prepared fields:
        %w[
          category_type_id team_affiliation_id team_id swimmer_id season_id
          entry_time_type_id number off_gogglecup fees_due
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
