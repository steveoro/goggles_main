# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'user_workshops/for_swimmer.html.haml' do
  # Test basic/required content:
  context 'when rendering with valid data,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:current_user) { GogglesDb::User.first(50).sample }
    let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }
    let(:fixture_params) { { id: fixture_row.id } }

    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid
      sign_in(current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      assign(:swimmer, fixture_row)
      controller.request.path_parameters.merge!(fixture_params)
      assign(:grid_filter_params, {})
      grid = UserWorkshopsGrid.new({}) do |scope|
        scope.for_swimmer(fixture_row).page(1).per(20)
      end
      assign(:grid, grid)
      render
    end

    it 'includes the title section' do
      expect(parsed_node.at_css('section#all-meetings-title')).to be_present
    end

    it 'includes the link to go back to the swimmer details page ("show swimmer", a.k.a. "swimmer dashboard")' do
      expect(parsed_node.at_css('#back-to-dashboard a')).to be_present
      expect(
        parsed_node.at_css('#back-to-dashboard a').attributes['href'].value
      ).to eq(swimmer_show_path(id: fixture_row.id))
    end

    it_behaves_like('MeetingGrid or UserWorkshopGrid datagrid partial with filtering and pagination')
  end
end
