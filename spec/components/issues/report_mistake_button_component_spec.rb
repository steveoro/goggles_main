# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Issues::ReportMistakeButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:result_row) do
    [
      GogglesDb::MeetingIndividualResult.last(500).sample,
      GogglesDb::UserResult.last(150).sample
    ].sample
  end

  before { expect(result_row).to be_an(GogglesDb::AbstractResult).and be_valid }

  context 'when specifying a valid parent result' do
    context 'and the current user can manage the result,' do
      subject { render_inline(described_class.new(result_row:, can_manage: true)) }

      let(:rendered_button) { subject.at_css("a#type1b1-btn-#{result_row.id}") }

      it 'renders the button' do
        expect(rendered_button).to be_present
      end

      it 'includes the target URL with the correct parameters' do
        target_href = issues_new_type1b1_path(
          result_id: result_row.id,
          result_class: result_row.class.name.split('::').last
        )
        expect(rendered_button['href']).to include(target_href.to_s)
      end

      it 'renders a red flag' do
        expect(rendered_button.at('i.fa.fa-flag-o.text-danger')).to be_present
      end
    end

    context 'but the current user cannot manage the result,' do
      subject { render_inline(described_class.new(result_row:, can_manage: false)).to_html }

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying an invalid parent result (even if the user can manage the result),' do
    subject do
      render_inline(
        described_class.new(
          result_row: ['not-a-parent-result', nil, GogglesDb::User.first(10).sample].sample,
          can_manage: true
        )
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
