# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MRR::TableComponent, type: :component do
  let(:fixture_mprg) do
    GogglesDb::MeetingProgram.joins(:meeting_relay_results)
                             .includes(:meeting_relay_results)
                             .first(100)
                             .sample
  end
  let(:mrrs) { fixture_mprg.meeting_relay_results }
  let(:reportable_row) { mrrs.sample }
  let(:editable_row) { mrrs.sample }

  before do
    expect(fixture_mprg).to be_a(GogglesDb::MeetingProgram).and be_valid
    expect(mrrs).to be_present
  end

  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(mrrs:, managed_team_ids: [])) }

    it 'renders a table body' do
      expect(subject.css('tbody:first-child')).to be_present
    end

    it 'renders as many table rows as the results specified' do
      expect(subject.css('tbody tr').count).to eq(mrrs.count)
    end

    it 'does not render the lap edit button (with no managed teams and a user with no Admin grants)' do
      parent_result_ids = mrrs.map(&:id)
      parent_result_ids.each do |parent_result_id|
        expect(subject.at_css("a#lap-req-edit-modal-#{parent_result_id}")).not_to be_present
      end
    end

    it 'does not render the report mistake button (when supplied with a team ID not included in the results)' do
      parent_result_ids = mrrs.map(&:id)
      parent_result_ids.each do |parent_result_id|
        expect(subject.at_css("a#type1b1-btn-#{parent_result_id}")).not_to be_present
      end
    end

    context 'when rendering a result row for which the user manages the team (and is not an Admin),' do
      subject do
        render_inline(
          described_class.new(mrrs:, managed_team_ids: [reportable_row.team_id], current_user_is_admin: false)
        )
      end

      before do
        expect(reportable_row).to be_a(GogglesDb::MeetingRelayResult)
        expect(reportable_row.team_id).to be_positive
      end

      it 'renders the report mistake button' do
        expect(subject.at_css("a#type1b1-btn-#{reportable_row.id}")).to be_present
      end
    end

    context 'when rendering a result row and the user is an Admin,' do
      subject do
        render_inline(
          described_class.new(mrrs:, managed_team_ids: [], current_user_is_admin: true)
        )
      end

      before do
        expect(reportable_row).to be_a(GogglesDb::MeetingRelayResult)
      end

      it 'renders the report mistake button' do
        expect(subject.at_css("a#type1b1-btn-#{reportable_row.id}")).to be_present
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # This won't work for an AbstractResult because UserResults aren't tied to a Team (and rightly so); thus we limit this to actual MIRs:
  context 'when rendering a result row for which the user can edit laps (MRR-only),' do
    subject do
      render_inline(
        described_class.new(mrrs:, managed_team_ids: [editable_row.team_id])
      )
    end

    before do
      expect(mrrs).to be_present
      expect(mrrs).to all be_a(GogglesDb::MeetingRelayResult)
      expect(editable_row).to be_a(GogglesDb::MeetingRelayResult)
      expect(editable_row.team_id).to be_positive
    end

    it 'renders the lap edit button' do
      expect(subject.at_css("a#lap-req-edit-modal-#{editable_row.id}")).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an invalid parameter,' do
    subject do
      render_inline(
        described_class.new(
          mrrs: ['not-a-list-of-results', [], nil, GogglesDb::User.first(10).sample].sample,
          managed_team_ids: nil
        )
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
