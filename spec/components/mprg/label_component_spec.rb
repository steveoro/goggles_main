# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mprg::LabelComponent, type: :component do
  context 'with a valid parameter,' do
    subject { render_inline(described_class.new(meeting_program: fixture_row)) }

    let(:fixture_row) { GogglesDb::MeetingProgram.first(100).sample }

    before { expect(fixture_row).to be_a(GogglesDb::MeetingProgram).and be_valid }

    it 'shows the meeting program label' do
      expect(subject.text).to include(fixture_row.event_type.label.to_s)
        .and include(fixture_row.category_type.short_name.to_s)
        .and include(fixture_row.gender_type.label.to_s)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_program: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
