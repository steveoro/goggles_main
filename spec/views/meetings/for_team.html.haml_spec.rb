# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/for_team.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with valid data,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:current_user) { GogglesDb::User.first(50).sample }
    # We have to make sure the chosen team does have a meeting otherwise the
    # decorator for the label will throw an error:
    let(:team_id_with_meetings) do
      GogglesDb::MeetingIndividualResult.includes(:team).select(:team_id)
                                        .distinct(:team_id).first(500)
                                        .pluck(:team_id)
                                        .sample
    end
    let(:fixture_row) { GogglesDb::Team.find(team_id_with_meetings) }
    let(:fixture_params) { { id: fixture_row.id } }

    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      expect(fixture_row).to be_a(GogglesDb::Team).and be_valid

      sign_in(current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      assign(:team, fixture_row)
      assign(:grid_filter_params, {})
      grid = MeetingsGrid.new({}) do |scope|
        scope.for_team(fixture_row).page(1).per(20)
      end
      assign(:grid, grid)
      controller.request.path_parameters.merge!(fixture_params)

      render
    end

    it 'includes the title section' do
      expect(parsed_node.at_css('section#all-meetings-title')).to be_present
    end

    it 'includes the link to go back to the team details page ("show team", a.k.a. "team dashboard")' do
      expect(parsed_node.at_css('#back-to-dashboard a')).to be_present
      expect(
        parsed_node.at_css('#back-to-dashboard a').attributes['href'].value
      ).to eq(team_show_path(id: fixture_row.id))
    end

    it_behaves_like('MeetingGrid or UserWorkshopGrid datagrid partial with filtering and pagination')
  end
end
