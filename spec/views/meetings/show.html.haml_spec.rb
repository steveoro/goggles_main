# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/show.html.haml' do
  # Test basic/required content:
  context 'when rendering with valid data,' do
    subject { rendered }

    let(:fixture_row) { GogglesDb::Meeting.first(100).sample }
    let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

    before do
      expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
      @meeting = fixture_row
      render
    end

    # Meeting header:
    # (From support/shared_component_examples.rb)
    it_behaves_like('an AbstractMeeting detail page rendering the meeting condensed_name text')
    it_behaves_like('an AbstractMeeting detail page rendering main \'header\' details')
    it_behaves_like('an AbstractMeeting detail page rendering the collapsed \'more\' details')

    # Meeting navs:
    it 'includes the meeting nav tabs section' do
      expect(parsed_node.at_css('section#meeting-navs')).to be_present
    end

    # Detailed results:
    it 'includes the meeting-show-results section table' do
      expect(parsed_node.at_css('section#meeting-show-results table')).to be_present
    end
  end
end
