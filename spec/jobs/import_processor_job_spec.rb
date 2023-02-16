# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/BeforeAfterAll
RSpec.describe ImportProcessorJob, type: :job do
  shared_examples_for 'ImportProcessorJob properly enqueued' do
    it "enqueues the job on the 'iq' queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue('iq')
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  context '(MicroTransactions) when the are IQ rows to process,' do
    # Clear junk from broken runs:
    before(:all) { GogglesDb::ImportQueue.delete_all }

    let(:solved_row) do
      FactoryBot.create(
        :import_queue,
        request_data: {
          'target_entity' => 'Swimmer',
          'swimmer' => { 'id' => GogglesDb::Swimmer.first(150).sample.id }
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

    it_behaves_like('ImportProcessorJob properly enqueued')

    context 'when there are rows marked as "done" (deletable),' do
      it 'consumes those IQ rows' do
        expect { described_class.perform_now }.to change { GogglesDb::ImportQueue.count }.by(-1)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context '(MacroTransactions) when the are SQL rows to process with a VALID script,' do
    # Clear junk from broken runs:
    before(:all) { GogglesDb::ImportQueue.delete_all }

    let(:row_with_valid_data) { FactoryBot.create(:import_queue_with_static_data_file) }

    before do
      expect(row_with_valid_data).to be_a(GogglesDb::ImportQueue).and be_valid
    end

    it "enqueues the job on the 'sql' queue" do
      expect { Delayed::Job.enqueue(described_class.new('sql'), queue: 'sql') }.to have_enqueued_job.on_queue('sql')
    end

    # (Can't test much else given the perform method is totally async from this by using a different connection pool)
  end

  context '(MacroTransactions) when the are SQL rows to process with an INVALID script,' do
    # Clear junk from broken runs:
    before(:all) { GogglesDb::ImportQueue.delete_all }

    let(:row_with_invalid_data) do
      fixture_row = FactoryBot.create(
        :import_queue,
        batch_sql: true
      )
      file_path = Rails.root.join('tmp', 'storage', "test-data-#{fixture_row.id}.sql")
      File.open(file_path, 'w') { |f| f.write('This is not valid SQL!') }
      fixture_row.data_file.attach(
        io: File.open(file_path),
        filename: File.basename(file_path),
        content_type: 'application/sql'
      )
      fixture_row
    end

    before do
      expect(row_with_invalid_data).to be_a(GogglesDb::ImportQueue).and be_valid
    end

    # Allow errors to bubble up in the job hierachy so that DelayedJob can handle them properly:
    it 'raises a Runtime error but nevertheless flags the row as deletable' do
      # NOTE: here we can test this because the throwing of the error makes the flow
      # jump back immediately to RSpec before the actual changes either take place or gets
      # rolled back at the end of the example.
      before_count = GogglesDb::ImportQueue.deletable.count
      expect { described_class.perform_now }.to raise_error(RuntimeError)
      after_count = GogglesDb::ImportQueue.deletable.count
      expect(before_count).to be < after_count
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the are no rows to process,' do
    # Clear junk from broken runs:
    before(:all) { GogglesDb::ImportQueue.delete_all }

    it_behaves_like('ImportProcessorJob properly enqueued') # test default enqueuing for no-ops
  end
end
# rubocop:enable RSpec/BeforeAfterAll
