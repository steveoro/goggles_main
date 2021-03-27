# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mprg::RowTitleComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_row) { GogglesDb::MeetingProgram.first(100).sample }
    before(:each) { expect(fixture_row).to be_a(GogglesDb::MeetingProgram).and be_valid }
    subject { render_inline(described_class.new(meeting_program: fixture_row)).to_html }

    it 'shows the meeting program label' do
      node = Nokogiri::HTML.fragment(subject).css('tr th b')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.event_type.label.to_s)
        .and include(fixture_row.category_type.short_name.to_s)
        .and include(fixture_row.gender_type.label.to_s)
    end
    it 'renders a linkable table row' do
      node = Nokogiri::HTML.fragment(subject).at_css('tr')
      expect(node).to be_present
      expect(node[:id]).to eq(
        "mprg-#{fixture_row.id}-#{fixture_row.category_type_id}-#{fixture_row.gender_type_id}"
      )
    end
    it 'renders a sticky table header spanning 4 columns' do
      node = Nokogiri::HTML.fragment(subject).at_css('tr th.sticky-header')
      expect(node).to be_present
      expect(node[:colspan]).to eq('4')
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(meeting_program: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
