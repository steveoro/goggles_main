# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssueCleanerJob, type: :job do
  shared_examples_for 'IssueCleanerJob properly enqueued' do
    it "enqueues the job on the 'issues' queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue('issues')
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  let(:issue_factory) do
    %i[
      issue_type0 issue_type1a issue_type1b issue_type1b1
      issue_type2b1 issue_type3b issue_type3c issue_type4
    ].sample
  end

  context 'when the are Issue rows' do
    before do
      FactoryBot.create_list(issue_factory, 5)
      5.times do
        FactoryBot.create(
          issue_factory,
          status: (GogglesDb::Issue::MAX_PROCESSABLE_STATE+1..6).to_a.sample,
          updated_at: IssueCleanerJob::OBSOLESCENCE_MARK - 1.minute
        )
      end
      expect(GogglesDb::Issue.count).to be >= 10
      expect(GogglesDb::Issue.deletable.count).to be >= 5
    end

    it_behaves_like('IssueCleanerJob properly enqueued')

    context 'and some of them are already processed and older than the OBSOLESCENCE_MARK,' do
      it 'deletes those rows' do
        expect { described_class.perform_now }.to change { GogglesDb::Issue.count }.by(-5)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
