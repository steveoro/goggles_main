# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Solver::UserLap, type: :integration do
  context 'when solving a deeply nested request,' do
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
end
# rubocop:enable Metrics/BlockLength
