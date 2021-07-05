# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting::TitleComponent, type: :component do
  [
    GogglesDb::Meeting.first(200).sample,
    GogglesDb::UserWorkshop.first(200).sample
  ].each do |abstract_meeting_instance|
    context "with a valid #{abstract_meeting_instance.class} parameter," do
      let(:fixture_row) { abstract_meeting_instance }
      before(:each) do
        expect(fixture_row.class.ancestors).to include(GogglesDb::AbstractMeeting)
        expect(fixture_row).to be_valid
      end
      subject { render_inline(described_class.new(meeting: fixture_row)) }

      it_behaves_like('an AbstractMeeting detail page rendering the meeting description text')
    end
  end

  [
    FactoryBot.create(:meeting, cancelled: true),
    FactoryBot.create(:user_workshop, cancelled: true)
  ].each do |abstract_meeting_instance|
    context "for a cancelled #{abstract_meeting_instance.class}," do
      let(:fixture_row) { abstract_meeting_instance }
      before(:each) do
        expect(fixture_row.class.ancestors).to include(GogglesDb::AbstractMeeting)
        expect(fixture_row).to be_valid
      end
      subject { render_inline(described_class.new(meeting: fixture_row)) }

      it_behaves_like('any subject that renders the \'cancelled\' stamp')
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
