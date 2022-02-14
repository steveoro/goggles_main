# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'user_workshops/show.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with valid data,' do
    subject { rendered }

    let(:fixture_row) { FactoryBot.create(:workshop_with_results) }

    before do
      expect(fixture_row).to be_a(GogglesDb::UserWorkshop).and be_valid
      @user_workshop = fixture_row
      render
    end

    it_behaves_like('an AbstractMeeting detail page rendering the meeting description text')
    it_behaves_like('an AbstractMeeting detail page rendering main \'header\' details')
    it_behaves_like('an AbstractMeeting detail page rendering the collapsed \'more\' details')
  end
end
