# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportProcessorJob do
  shared_examples_for 'ImportProcessorJob properly enqueued' do
    it "enqueues the job on the 'iq' queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue('iq')
    end
  end

  # NOTE: the test DB is shared with other suites, so each example clears the queue
  # only *inside* its own transaction (rolled back at the end) instead of committing
  # a global delete in a before(:all) hook.
  before { GogglesDb::ImportQueue.delete_all }
  #-- -----------------------------------------------------------------------
  #++

  context '(MicroTransactions) when the are IQ rows to process,' do
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
        expect { described_class.perform_now }.to change(GogglesDb::ImportQueue, :count).by(-1)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context '(MacroTransactions) when the are SQL rows to process with a VALID script,' do
    let(:row_with_valid_data) { FactoryBot.create(:import_queue_with_static_data_file, batch_sql: true) }
    let(:success_status) { instance_double(Process::Status, success?: true, exitstatus: 0) }

    before do
      expect(row_with_valid_data).to be_a(GogglesDb::ImportQueue).and be_valid
      allow(Open3).to receive(:capture3).and_return(['', '', success_status])
    end

    it "enqueues the job on the 'sql' queue" do
      expect { described_class.perform_later('sql') }.to have_enqueued_job.on_queue('sql')
    end

    it 'runs the attached script (through the stubbed DB client) and marks the row as applied' do
      described_class.perform_now
      expect(Open3).to have_received(:capture3).once
      expect(row_with_valid_data.reload).to have_attributes(done: true, error_messages: nil, process_runs: 1)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the are no rows to process,' do
    it_behaves_like('ImportProcessorJob properly enqueued') # test default enqueuing for no-ops
  end
  #-- -------------------------------------------------------------------------
  #++

  # == Batch SQL rows: outcome, run order, blocking, retention & maintenance window.
  #
  # Every shell call is stubbed (no SQL ever reaches a DB client) and each example starts
  # from an empty queue *inside* its own rolled-back transaction (see the top-level hook),
  # so nothing committed by the other suites sharing the test DB is touched.
  describe 'batch SQL rows' do
    let(:failure_status) { instance_double(Process::Status, success?: false, exitstatus: 1) }
    let(:success_status) { instance_double(Process::Status, success?: true, exitstatus: 0) }
    let(:duplicate_key_error) { "ERROR 1062 (23000) at line 1: Duplicate entry '1' for key 'PRIMARY'" }
    let(:executed) { [] } # SQL contents handed to the DB client, in run order
    let(:shell_calls) { [] } # one Hash (env, cmd, path, maintenance flag) per client call
    let(:solver) { instance_double(IqSolverService, call: nil) }

    before do
      GogglesDb::AppParameter.maintenance = false
      allow(IqSolverService).to receive(:new).and_return(solver)
      allow(Open3).to receive(:capture3) { |*args| fake_db_client(*args) }
    end

    # Fake DB client: reads the SQL file referenced by the shell command and fails
    # whenever its contents include the 'FAILING' marker.
    def fake_db_client(*args)
      cmd = args.last
      path = Shellwords.split(cmd[/cat\s+(\S+?);/, 1]).first
      sql = File.read(path)
      executed << sql.strip
      shell_calls << { env: args.first.is_a?(Hash) ? args.first : {}, cmd:, path:, maintenance: GogglesDb::AppParameter.maintenance? }
      sql.include?('FAILING') ? ['', duplicate_key_error, failure_status] : ['', '', success_status]
    end

    # Creates a batch row with an attached SQL file storing +sql+.
    def batch_row(sql, **attributes)
      row = FactoryBot.create(:import_queue, batch_sql: true, **attributes)
      row.data_file.attach(io: StringIO.new(sql), filename: "batch-#{row.id}.sql", content_type: 'application/sql')
      row.reload # (the attachment touches the row, bumping its lock_version)
    end

    def perform_job
      described_class.perform_now
    end

    context 'when a script fails,' do
      let!(:failing_row) { batch_row('-- FAILING script') }
      let!(:later_row) { batch_row('-- later script') }

      it 'does not raise' do
        expect { described_class.perform_now }.not_to raise_error
      end

      it 'turns the maintenance flag off again' do
        perform_job
        expect(GogglesDb::AppParameter.maintenance?).to be false
      end

      it 'keeps the failed row with its error_messages and done: false' do
        perform_job
        expect(failing_row.reload).to have_attributes(done: false, process_runs: 1)
        expect(failing_row.error_messages).to include('ERROR 1062')
      end

      it 'does not run the later rows, neither now nor on the next run' do
        2.times { perform_job }
        expect(executed).to eq(['-- FAILING script'])
        expect(later_row.reload).to have_attributes(done: false, process_runs: 0, error_messages: nil)
      end
    end

    context 'when a failed batch row is already in the queue,' do
      let!(:failed_row) { batch_row('-- fixed script', process_runs: 1, error_messages: duplicate_key_error) }
      let!(:queued_row) { batch_row('-- queued script') }
      let!(:micro_row) { FactoryBot.create(:import_queue) }

      it 'processes a micro-transaction row anyway' do
        perform_job
        expect(solver).to have_received(:call).with(micro_row)
      end

      it 'runs no batch script and leaves the maintenance flag alone (blocked)' do
        allow(GogglesDb::AppParameter).to receive(:maintenance=).and_call_original
        perform_job
        expect(Open3).not_to have_received(:capture3)
        expect(GogglesDb::AppParameter).not_to have_received(:maintenance=)
        expect(failed_row.reload).to have_attributes(done: false, error_messages: duplicate_key_error)
        expect(queued_row.reload).to have_attributes(done: false, process_runs: 0)
      end

      it 'runs it and the queued rows in id order once reset for a retry' do
        failed_row.update!(error_messages: '', process_runs: 0) # (= API PUT retry in place)
        perform_job
        expect(executed).to eq(['-- fixed script', '-- queued script'])
        expect([failed_row.reload.done, queued_row.reload.done]).to all(be true)
      end
    end

    context 'when two scripts are queued,' do
      let!(:first_row) { batch_row('-- first') }
      let!(:second_row) { batch_row('-- second') }

      it 'runs them in id order' do
        perform_job
        expect(executed).to eq(['-- first', '-- second'])
      end

      it 'marks both as applied, keeping rows and files in the queue' do
        perform_job
        [first_row, second_row].each do |row|
          expect(row.reload).to have_attributes(done: true, error_messages: nil, process_runs: 1)
          expect(row.data_file).to be_attached
        end
      end

      it 'runs both inside a single maintenance window, closed afterwards' do
        perform_job
        expect(shell_calls.pluck(:maintenance)).to eq([true, true])
        expect(GogglesDb::AppParameter.maintenance?).to be false
      end
    end

    context 'when an applied row is in the queue,' do
      let!(:applied_row) { batch_row('-- applied', done: true, process_runs: 1) }

      it 'keeps it on the next run' do
        perform_job
        expect(GogglesDb::ImportQueue.exists?(applied_row.id)).to be true
      end

      it 'opens no maintenance window when nothing is queued' do
        allow(GogglesDb::AppParameter).to receive(:maintenance=).and_call_original
        perform_job
        expect(GogglesDb::AppParameter).not_to have_received(:maintenance=)
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context 'when applied rows are older than the retention period,' do
      let!(:expired_row) { batch_row('-- old', done: true, process_runs: 1).tap { |row| row.update!(updated_at: 15.days.ago) } }
      let!(:recent_row) { batch_row('-- recent', done: true, process_runs: 1).tap { |row| row.update!(updated_at: 13.days.ago) } }

      it 'deletes the expired row and purges its file, keeping the recent one' do
        blob_id = expired_row.data_file.blob.id
        perform_job
        expect(GogglesDb::ImportQueue.exists?(expired_row.id)).to be false
        expect(ActiveStorage::Blob.exists?(blob_id)).to be false
        expect(GogglesDb::ImportQueue.exists?(recent_row.id)).to be true
      end
    end

    context 'when a row was left running by an interrupted run,' do
      let!(:interrupted_row) { batch_row('-- interrupted', process_runs: 1) }
      let!(:later_row) { batch_row('-- later') }

      it "marks it failed with 'interrupted: outcome unknown' and runs nothing" do
        perform_job
        expect(interrupted_row.reload).to have_attributes(done: false, error_messages: 'interrupted: outcome unknown')
        expect(executed).to be_empty
        expect(later_row.reload.process_runs).to eq(0)
      end
    end

    context 'when the maintenance mode is already on,' do
      let!(:queued_row) { batch_row('-- queued') }

      before do
        GogglesDb::AppParameter.maintenance = true
        allow(GogglesDb::AppParameter).to receive(:maintenance=).and_call_original
      end

      it 'runs the script and leaves the maintenance flag untouched' do
        perform_job
        expect(queued_row.reload.done).to be true
        expect(GogglesDb::AppParameter).not_to have_received(:maintenance=)
        expect(GogglesDb::AppParameter.maintenance?).to be true
      end
    end

    context 'when done micro-transaction rows and retained batch rows are both present,' do
      let!(:done_micro_row) { FactoryBot.create(:import_queue, done: true) }
      let!(:applied_row) { batch_row('-- applied', done: true, process_runs: 1) }
      let!(:failed_row) { batch_row('-- FAILING', process_runs: 1, error_messages: duplicate_key_error) }

      it 'cleans up only the micro-transaction rows' do
        perform_job
        expect(GogglesDb::ImportQueue.exists?(done_micro_row.id)).to be false
        expect(GogglesDb::ImportQueue.exists?(applied_row.id)).to be true
        expect(GogglesDb::ImportQueue.exists?(failed_row.id)).to be true
      end
    end

    context 'when a batch row has no data file attached,' do
      let!(:fileless_row) { FactoryBot.create(:import_queue, batch_sql: true) }
      let!(:later_row) { batch_row('-- later') }

      it 'marks it failed and does not run the later rows' do
        perform_job
        expect(fileless_row.reload).to have_attributes(done: false, process_runs: 1)
        expect(fileless_row.error_messages).to be_present
        expect(executed).to be_empty
        expect(later_row.reload.process_runs).to eq(0)
      end
    end

    context 'when the client error output is huge,' do
      let!(:failing_row) { batch_row('-- FAILING') }

      before { allow(Open3).to receive(:capture3).and_return(['', "ERROR 1064 #{'x' * 70_000}", failure_status]) }

      it 'stores at most 60_000 bytes of it' do
        perform_job
        expect(failing_row.reload.error_messages.bytesize).to be <= 60_000
        expect(failing_row.error_messages).to start_with('ERROR 1064')
      end
    end

    context 'when the client error output includes characters the column charset may reject,' do
      let!(:failing_row) { batch_row('-- FAILING') }

      before { allow(Open3).to receive(:capture3).and_return(['', "ERROR 1062 (23000): Duplicate entry 'Łukasz 🏊'", failure_status]) }

      it 'stores the error anyway (as ASCII, if needed)' do
        perform_job
        expect(failing_row.reload.done).to be false
        expect(failing_row.error_messages).to start_with('ERROR 1062 (23000)')
      end
    end

    context 'when running a script,' do
      let!(:queued_row) { batch_row('-- queued') }
      let(:job) { described_class.new }

      before { allow(job).to receive(:from_database_config).and_return(%w[fake_db fake_user fake-password fake-host]) }

      it 'passes the password through MYSQL_PWD, never on the command line' do
        job.perform_now
        expect(shell_calls.first[:env]).to include('MYSQL_PWD' => 'fake-password')
        expect(shell_calls.first[:cmd]).not_to include('fake-password')
        expect(shell_calls.first[:cmd]).to include('--database=fake_db')
        expect(queued_row.reload.done).to be true
      end

      it 'writes the temp SQL file under Dir.tmpdir (not db/dump) and removes it afterwards' do
        job.perform_now
        expect(shell_calls.first[:path]).to start_with(Dir.tmpdir)
        expect(shell_calls.first[:path]).not_to include('db/dump')
        expect(File.exist?(shell_calls.first[:path])).to be false
      end
    end

    describe 'concurrency control' do
      it 'allows a single running instance, discarding any overlapping run' do
        expect(described_class.concurrency_key).to eq('import_processor')
        expect(described_class.concurrency_limit).to eq(1)
        expect(described_class.concurrency_duration).to eq(30.minutes)
        expect(described_class.concurrency_on_conflict).to eq(:discard)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#from_database_config' do
    subject(:database_config) { described_class.new.send(:from_database_config) }

    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      allow(Rails.configuration).to receive(:database_configuration).and_return(
        'production' => {
          'primary' => {
            'database' => 'goggles',
            'username' => 'root',
            'password' => 'secret',
            'host' => 'goggles-db'
          },
          'queue' => {
            'database' => 'storage/production_queue.sqlite3'
          }
        }
      )
    end

    it 'uses the primary database config when the environment has multiple databases' do
      expect(database_config).to eq(%w[goggles root secret goggles-db])
    end
  end
end
