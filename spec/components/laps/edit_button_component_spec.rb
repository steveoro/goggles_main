# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Laps::EditButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:parent_result) do
    [
      GogglesDb::MeetingIndividualResult.last(500).sample,
      GogglesDb::UserResult.last(150).sample
    ].sample
  end

  before { expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid }

  context 'when specifying a valid parent result' do
    context 'and the current user can manage the laps,' do
      subject { render_inline(described_class.new(parent_result: parent_result, can_manage: true)) }

      let(:rendered_button) { subject.at_css("a#lap-req-edit-modal-#{parent_result.id}") }

      it 'renders the button' do
        expect(rendered_button).to be_present
      end

      it 'includes the target URL with the correct parameters' do
        target_href = laps_edit_modal_path(
          result_id: parent_result.id,
          result_class: parent_result.class.name.split('::').last
        )
        expect(rendered_button['href']).to include(target_href.to_s)
      end

      it 'renders a pencil icon' do
        expect(rendered_button.at('i.fa.fa-pencil-square-o')).to be_present
      end
    end

    context 'but the current user cannot manage the laps,' do
      subject { render_inline(described_class.new(parent_result: parent_result, can_manage: false)).to_html }

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying an invalid parent result (even if the user can manage the laps),' do
    subject do
      render_inline(
        described_class.new(
          parent_result: ['not-a-parent-result', nil, GogglesDb::User.first(10).sample].sample,
          can_manage: true
        )
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
