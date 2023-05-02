# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Solver::UserLap, type: :integration do
  #
  # MULTIPLE requests, each with mixed NEW & EXISTING VALID data
  # (some parent entities are new, some are existing => bind all laps to same UR)
  #
  context 'when solving a group of multi-user_lap chrono requests from a fixture,' do
    let(:array_of_req_hash) do
      JSON.parse(File.read("#{GogglesDb::Engine.root}/spec/fixtures/7x_swimmer-23_chrono.json"))
    end

    before do
      expect(array_of_req_hash).to be_an(Array).and be_present
      expect(array_of_req_hash).to all be_an(Hash)
      expect(array_of_req_hash.count).to eq(7)
    end

    context 'having solvable #req data (each row belonging to the same parent),' do
      7.times do |index|
        describe "processing row #{index + 1}," do
          subject do
            solver = Solver::Factory.for('UserLap', array_of_req_hash[index])
            solver.solve!
            solver
          end

          describe '#solved?' do
            it 'is true' do
              expect(subject.solved?).to be true
            end
          end

          describe '#entity' do
            it 'is of the expected target entity type (UserLap)' do
              expect(subject.entity).to be_a(GogglesDb::UserLap)
              expect(subject.entity.id).to be_positive
            end

            it 'is bound to the expected existing swimmer' do
              expect(subject.entity.swimmer_id.to_s).to eq(array_of_req_hash[index]['user_lap']['swimmer']['id'])
              expect(subject.entity.user_result.swimmer_id.to_s).to eq(array_of_req_hash[index]['user_lap']['swimmer']['id'])
            end

            it 'is bound to the expected existing swimming pool' do
              expect(subject.entity.user_result.swimming_pool_id.to_s).to eq(array_of_req_hash[index]['user_lap']['user_result']['swimming_pool']['id'])
            end

            %i[
              length_in_meters minutes seconds hundredths
              minutes_from_start seconds_from_start hundredths_from_start
            ].each do |column_name|
              it "has the expected #{column_name}" do
                expect(subject.entity.send(column_name)).to eq(array_of_req_hash[index]['user_lap'][column_name.to_s])
              end
            end
          end
        end
      end
      #-- ---------------------------------------------------------------------
      #++

      context 'after sorting out all rows, the whole group' do
        it 'is bound to the same UserResult parent' do
          results = []
          array_of_req_hash.each_with_index do |request_hash, _index|
            solver = Solver::Factory.for('UserLap', request_hash)

            solver.solve!
            expect(solver).to be_solved
            expect(solver.entity).to be_a(GogglesDb::UserLap).and be_valid
            results << solver.entity
          end

          expect(results.map(&:user_result_id).uniq).to eq([results.first.user_result_id])
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  #
  # INDIVIDUAL request, NEW & EXISTING VALID data
  #
  context 'when solving a single deeply nested request,' do
    [
      # depth 4 - Complete breadth (full request layout sample)
      lambda { |row|
        {
          'user_lap' => {
            'user_result' => {
              'user_workshop' => {
                'description' => row.user_result.user_workshop.description,
                'header_date' => row.user_result.user_workshop.header_date,
                'header_year' => row.user_result.user_workshop.header_year,
                'user_id' => row.user_result.user_workshop.user_id,
                'team' => {
                  'name' => row.user_result.user_workshop.team.name,
                  'city_id' => row.user_result.user_workshop.team.city_id
                },
                'season' => {
                  'header_year' => row.user_result.user_workshop.season.header_year,
                  'description' => row.user_result.user_workshop.season.description,
                  'begin_date' => row.user_result.user_workshop.season.begin_date,
                  'end_date' => row.user_result.user_workshop.season.end_date,
                  'edition' => row.user_result.user_workshop.season.edition,
                  'season_type_id' => row.user_result.user_workshop.season.season_type_id,
                  'edition_type_id' => row.user_result.user_workshop.season.edition_type_id,
                  'timing_type_id' => row.user_result.user_workshop.season.timing_type_id
                }
              }, # (UserWorkshop end)

              'user_id' => row.user_result.user_id,
              # (nested swimmer defs have priority and can be differentiated from root level thanks to nesting)
              'swimmer' => {
                'complete_name' => row.user_result.swimmer.complete_name,
                'year_of_birth' => row.user_result.swimmer.year_of_birth,
                'gender_type_id' => row.user_result.swimmer.gender_type_id
              },
              'swimming_pool' => { 'id' => row.user_result.swimming_pool_id },
              'category_type_id' => row.user_result.category_type_id,
              'pool_type_id' => row.user_result.pool_type_id,
              'event_type_id' => row.user_result.event_type_id,
              'event_date' => row.user_result.event_date
            }, # (UserResult end)

            # Members @ root level: (belong to UserLap & may differ from nested ones)
            'swimmer' => {
              'complete_name' => row.swimmer.complete_name,
              'year_of_birth' => row.swimmer.year_of_birth,
              'gender_type_id' => row.swimmer.gender_type_id
            },
            'length_in_meters' => row.length_in_meters,
            'reaction_time' => row.reaction_time,
            'minutes' => row.minutes,
            'seconds' => row.seconds,
            'hundredths' => row.hundredths,
            'position' => row.position,
            'minutes_from_start' => row.minutes_from_start,
            'seconds_from_start' => row.seconds_from_start,
            'hundredths_from_start' => row.hundredths_from_start
          } # (UserLap end)
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

        let(:fixture_row) do
          FactoryBot.create(
            :user_lap,
            # Make sure the result does have an associated event date:
            # (NOTE: user_result factory up to version <= 0.2.18 used to set event_date to nil)
            user_result: FactoryBot.create(:user_result, event_date: Time.zone.today)
          )
        end
        let(:fixture_req) { req.call(fixture_row) }
        let(:expected_id) { fixture_row.id }

        it_behaves_like('Solver strategy, OPTIONAL bindings, solvable req, after #solve!', GogglesDb::UserLap)

        describe '#entity' do
          # Check just the most important fields for speed: (the others are already checked
          # in the non-integration counter part example)
          %i[
            user_result_id swimmer_id length_in_meters
            minutes seconds hundredths
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
          # Check just the most important fields for speed:
          %i[
            user_result_id swimmer_id length_in_meters
            minutes seconds hundredths
          ].each do |column_name|
            it "has the expected #{column_name}" do
              expect(subject.entity.send(column_name)).to eq(fixture_row.send(column_name))
            end
          end
        end
      end
      #-- -----------------------------------------------------------------------
      #++
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Metrics/BlockLength
