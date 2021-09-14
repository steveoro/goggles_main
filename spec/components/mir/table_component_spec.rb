# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MIR::TableComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(mirs: fixture_mprg.meeting_individual_results)) }

    let(:fixture_mprg) do
      GogglesDb::MeetingProgram.joins(:meeting_individual_results)
                               .includes(:meeting_individual_results)
                               .first(100)
                               .sample
    end

    before do
      expect(fixture_mprg).to be_a(GogglesDb::MeetingProgram).and be_valid
      expect(fixture_mprg.meeting_individual_results.count).to be_positive
    end

    it 'renders a table body' do
      expect(subject.css('tbody:first-child')).to be_present
    end

    it 'renders as many table rows as the results specified' do
      expect(subject.css('tbody tr').count).to eq(fixture_mprg.meeting_individual_results.count)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(mirs: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
