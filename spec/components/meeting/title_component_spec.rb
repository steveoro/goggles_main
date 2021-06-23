# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting::TitleComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_row) { GogglesDb::Meeting.first(100).sample }
    before(:each) { expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid }
    subject { render_inline(described_class.new(meeting: fixture_row)) }

    it_behaves_like('a Meeting detail page rendering the meeting description text')
  end

  context 'for a cancelled meeting,' do
    let(:fixture_row) { FactoryBot.create(:meeting, cancelled: true) }
    before(:each) { expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid }
    subject { render_inline(described_class.new(meeting: fixture_row)) }

    it_behaves_like('any subject that renders the \'cancelled\' stamp')
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
