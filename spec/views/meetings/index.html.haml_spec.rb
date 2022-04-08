# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/index.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with valid data,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:current_user) { GogglesDb::User.find([1, 2, 4].sample) }

    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      expect(current_user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid

      sign_in(current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(current_user)
      assign(:swimmer, current_user.swimmer)
      grid = MeetingsGrid.new do |scope|
        scope.for_swimmer(current_user.swimmer).page(1).per(10)
      end
      assign(:grid, grid)

      render
    end

    it 'includes the section title' do
      expect(parsed_node.at_css('section#my-past-meetings-title')).to be_present
      expect(parsed_node.at_css('section#my-past-meetings-title h4').text.strip).to eq(I18n.t('home.my.past_title'))
    end

    it_behaves_like('AbstractMeeting rendered /index view')
  end
end
