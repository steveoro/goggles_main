# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/show.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with valid data,' do
    subject { rendered }

    let(:fixture_row) { GogglesDb::Meeting.first(100).sample }

    before do
      expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
      @meeting = fixture_row
      render
    end

    it_behaves_like('an AbstractMeeting detail page rendering the meeting condensed_name text')
    it_behaves_like('an AbstractMeeting detail page rendering main \'header\' details')
    it_behaves_like('an AbstractMeeting detail page rendering the collapsed \'more\' details')
  end
end
