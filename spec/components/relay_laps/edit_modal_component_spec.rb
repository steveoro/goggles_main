# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelayLaps::EditModalComponent, type: :component do
  include Rails.application.routes.url_helpers

  # Most complete case: MRR w/ MRS + RelayLaps (typical case: 4x100m or 4x200m)
  # Each MRS will target whole lengths (100m or 200m) while RelayLaps
  # will handle "sub-laps" for each MRS swimmer; the MRS row will store the final
  # delta.
  let(:mrs_with_relay_laps) do
    GogglesDb::RelayLap.includes(:meeting_relay_swimmer)
                       .joins(:meeting_relay_swimmer)
                       .last(250)
                       .sample.parent_result
  end

  let(:relay_result) { mrs_with_relay_laps.meeting_relay_result }
  let(:fixture_relay_lap) { mrs_with_relay_laps.relay_laps.sample }

  before do
    expect(relay_result).to be_an(GogglesDb::MeetingRelayResult).and be_valid
    expect(mrs_with_relay_laps).to be_an(GogglesDb::MeetingRelaySwimmer).and be_valid
    expect(mrs_with_relay_laps.relay_laps).not_to be_empty
    expect(fixture_relay_lap).to be_a(GogglesDb::RelayLap).and be_valid
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying a valid parent relay result with existing laps' do
    subject { render_inline(described_class.new(relay_result:)) }

    let(:rendered_modal) { subject.at_css('#lap-edit-modal.modal.fade') }

    it 'renders the modal container (& contents) as initially hidden' do
      expect(rendered_modal).to be_present
    end

    it 'includes the edit modal content container' do
      expect(rendered_modal.at('#lap-edit-modal-contents')).to be_present
    end

    it_behaves_like('RelayLaps::EditModalContentsComponent rendered with some existing laps & sublaps')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying an invalid parent result,' do
    subject do
      render_inline(
        described_class.new(relay_result: ['not-a-parent-result', nil, GogglesDb::User.first(10).sample].sample)
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
