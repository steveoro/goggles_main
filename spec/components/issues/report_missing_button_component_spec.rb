# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Issues::ReportMissingButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:parent_meeting) do
    [
      GogglesDb::Meeting.last(150).sample,
      GogglesDb::UserWorkshop.last(150).sample
    ].sample
  end

  let(:event_type) { GogglesDb::EventType.all_eventable.sample }

  before do
    expect(parent_meeting).to be_an(GogglesDb::AbstractMeeting).and be_valid
    expect(event_type).to be_an(GogglesDb::EventType).and be_valid
  end

  context 'when specifying valid parameters,' do
    subject { render_inline(described_class.new(parent_meeting: parent_meeting, event_type: event_type)) }

    let(:rendered_button) { subject.at_css("a#type1b-btn-#{parent_meeting.id}-#{event_type.id}") }

    it 'renders the button' do
      expect(rendered_button).to be_present
    end

    it 'includes the target URL with the correct parameters' do
      target_href = issues_new_type1b_path(
        parent_meeting_id: parent_meeting.id,
        parent_meeting_class: parent_meeting.class.name.split('::').last,
        event_type_id: event_type.id
      )
      expect(rendered_button['href']).to include(target_href.to_s)
    end

    it 'renders a flag with a label' do
      expect(rendered_button.at('span i.fa.fa-flag-o')).to be_present
      expect(rendered_button.at('span').text).to include(I18n.t('issues.type1b.form.btn_label'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying a invalid parameters,' do
    subject do
      render_inline(
        described_class.new(
          parent_meeting: ['not-a-parent-result', nil, GogglesDb::User.first(10).sample].sample,
          event_type: [event_type, nil].sample
        )
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
