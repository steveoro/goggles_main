# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Lap, type: :integration do
  #
  # MULTIPLE requests, each with mixed NEW & EXISTING VALID data
  # (some parent entities are new, some are existing => bind all laps to same MIR)
  #
  context 'when solving a group of multi-lap chrono requests from a fixture,' do
    let(:array_of_req_hash) do
      JSON.parse(File.read("#{GogglesDb::Engine.root}/spec/fixtures/3x_swimmer-142_chrono.json"))
    end

    before do
      expect(array_of_req_hash).to be_an(Array).and be_present
      expect(array_of_req_hash).to all be_an(Hash)
      expect(array_of_req_hash.count).to eq(3)
    end

    context 'having solvable #req data (each row belonging to the same parent),' do
      3.times do |index|
        describe "processing row #{index + 1}," do
          subject do
            solver = Solver::Factory.for('Lap', array_of_req_hash[index])
            solver.solve!
            solver
          end

          describe '#solved?' do
            it 'is true' do
              expect(subject.solved?).to be true
            end
          end

          describe '#entity' do
            it 'is of the expected target entity type (Lap)' do
              expect(subject.entity).to be_a(GogglesDb::Lap)
              expect(subject.entity.id).to be_positive
            end

            it 'is bound to the expected existing swimmer' do
              expect(subject.entity.swimmer_id.to_s).to eq(array_of_req_hash[index]['lap']['swimmer']['id'])
            end

            it 'is bound to the expected existing team' do
              expect(subject.entity.team_id.to_s).to eq(array_of_req_hash[index]['lap']['team']['id'])
            end

            %i[
              length_in_meters minutes seconds hundredths
              minutes_from_start seconds_from_start hundredths_from_start
            ].each do |column_name|
              it "has the expected #{column_name}" do
                expect(subject.entity.send(column_name)).to eq(array_of_req_hash[index]['lap'][column_name.to_s])
              end
            end
          end
        end
      end
      #-- ---------------------------------------------------------------------
      #++

      # This test is critical for asserting the whole Solver chain works.
      # (If the MIR parent are multiple => different MIRs have been created
      # for different Laps => != MPRGs => != MEvs => != MSess)
      context 'after sorting out all rows, the whole group' do
        it 'is bound to the same MIR parent' do
          results = []
          array_of_req_hash.each_with_index do |request_hash, _index|
            solver = Solver::Factory.for('Lap', request_hash)

            solver.solve!
            expect(solver).to be_solved
            expect(solver.entity).to be_a(GogglesDb::Lap).and be_valid
            results << solver.entity
          end

          expect(results.map(&:meeting_individual_result_id).uniq).to eq([results.first.meeting_individual_result_id])
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
