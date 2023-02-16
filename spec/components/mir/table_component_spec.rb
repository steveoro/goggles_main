# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MIR::TableComponent, type: :component do
  context 'with a valid list of results,' do
    subject do
      render_inline(
        described_class.new(
          mirs: mirs,
          # Disable row action buttons for this context:
          managed_team_ids: [],
          current_swimmer_id: 0
        )
      )
    end

    let(:mirs) do
      [
        GogglesDb::UserWorkshop.includes(:user_results).joins(:user_results)
                               .sample
                               .user_results,
        GogglesDb::MeetingProgram.joins(:meeting_individual_results)
                                 .includes(:meeting_individual_results)
                                 .last(500).sample
                                 .meeting_individual_results
      ].sample
    end

    before do
      expect(mirs.count).to be_positive
      expect(mirs).to all be_a(GogglesDb::AbstractResult)
    end

    it 'renders a table body' do
      expect(subject.css('tbody:first-child')).to be_present
    end

    it 'renders as many table rows as the results specified' do
      expect(subject.css('tbody.resut-table-row').count).to eq(mirs.count)
    end

    it 'does not render the lap edit button (when supplied with an empty list of managed teams)' do
      parent_result_ids = mirs.map(&:id)
      parent_result_ids.each do |parent_result_id|
        expect(subject.at_css("a#lap-req-edit-modal-#{parent_result_id}")).not_to be_present
      end
    end

    it 'does not render the report mistake button (when supplied with a swimmer ID not included in the results)' do
      parent_result_ids = mirs.map(&:id)
      parent_result_ids.each do |parent_result_id|
        expect(subject.at_css("a#type1b1-btn-#{parent_result_id}")).not_to be_present
      end
    end

    context 'when rendering a result row for which the user can report a mistake,' do
      subject do
        render_inline(
          described_class.new(mirs: mirs, managed_team_ids: [], current_swimmer_id: reportable_row.swimmer_id)
        )
      end

      let(:reportable_row) { mirs.sample }

      before do
        expect(reportable_row).to be_a(GogglesDb::AbstractResult)
        expect(reportable_row.swimmer_id).to be_positive
      end

      it 'renders the lap edit button' do
        expect(subject.at_css("a#type1b1-btn-#{reportable_row.id}")).to be_present
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # This won't work for an AbstractResult because UserResults aren't tied to a Team (and rightly so); thus we limit this to actual MIRs:
  context 'when rendering a result row for which the user can edit laps (MIR-only),' do
    subject do
      render_inline(
        described_class.new(mirs: pure_mirs, managed_team_ids: [editable_row.team_id], current_swimmer_id: 0)
      )
    end

    let(:pure_mirs) do
      GogglesDb::MeetingProgram.joins(:meeting_individual_results)
                               .includes(:meeting_individual_results)
                               .last(500).sample
                               .meeting_individual_results
    end

    let(:editable_row) { pure_mirs.sample }

    before do
      expect(pure_mirs.count).to be_positive
      expect(pure_mirs).to all be_a(GogglesDb::MeetingIndividualResult)
      expect(editable_row).to be_a(GogglesDb::MeetingIndividualResult)
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
          mirs: ['not-a-list-of-results', [], nil, GogglesDb::User.first(10).sample].sample,
          managed_team_ids: nil, current_swimmer_id: nil
        )
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
