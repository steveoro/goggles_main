# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mprg::LabelComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_row) { GogglesDb::MeetingProgram.first(100).sample }
    before(:each) { expect(fixture_row).to be_a(GogglesDb::MeetingProgram).and be_valid }
    subject { render_inline(described_class.new(meeting_program: fixture_row)).to_html }

    it 'shows the meeting program label' do
      expect(subject).to include(fixture_row.event_type.label.to_s)
        .and include(fixture_row.category_type.short_name.to_s)
        .and include(fixture_row.gender_type.label.to_s)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_program: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
