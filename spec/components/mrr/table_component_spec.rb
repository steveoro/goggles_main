# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MRR::TableComponent, type: :component do
  context 'with a valid parameter,' do
    let(:fixture_mprg) do
      GogglesDb::MeetingProgram.joins(:meeting_relay_results)
                               .includes(:meeting_relay_results)
                               .first(100)
                               .sample
    end
    before(:each) do
      expect(fixture_mprg).to be_a(GogglesDb::MeetingProgram).and be_valid
      expect(fixture_mprg.meeting_relay_results.count).to be_positive
    end

    subject { render_inline(described_class.new(mrrs: fixture_mprg.meeting_relay_results)).to_html }

    it 'renders a table body' do
      node = Nokogiri::HTML.fragment(subject).css('tbody:first-child')
      expect(node).to be_present
    end
    it 'renders as many table rows as the results specified' do
      node = Nokogiri::HTML.fragment(subject).css('tbody tr')
      expect(node.count).to eq(fixture_mprg.meeting_relay_results.count)
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(mrrs: nil)).to_html }
    it_behaves_like('any subject that renders nothing')
  end
end
