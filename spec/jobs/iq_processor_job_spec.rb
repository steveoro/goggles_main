# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IqProcessorJob, type: :job do
  shared_examples_for 'IqProcessorJob properly enqueued' do
    it "enqueues the job on the 'iq' queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue('iq')
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  context 'when the are IQ rows to process,' do
    # Clear junk from broken runs:
    before(:all) { GogglesDb::ImportQueue.delete_all }

    let(:solved_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => GogglesDb::Swimmer.select(:id).first(150).sample.id }
        }.to_json,
        done: true
      )
    end
    let(:unsolvable_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => -1 }
        }.to_json
      )
    end

    before do
      expect(solved_row).to be_a(GogglesDb::ImportQueue).and be_valid
      expect(unsolvable_row).to be_a(GogglesDb::ImportQueue).and be_valid
    end

    it_behaves_like('IqProcessorJob properly enqueued')

    context 'if there are rows marked as solved,' do
      it 'consumes the IQ solved rows' do
        expect { described_class.perform_now }.to change { GogglesDb::ImportQueue.count }.by(-1)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the are no rows to process,' do
    # Clear junk from broken runs:
    before(:all) { GogglesDb::ImportQueue.delete_all }

    it_behaves_like('IqProcessorJob properly enqueued')
  end
end
