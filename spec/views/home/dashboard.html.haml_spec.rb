# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/dashboard.html.haml', type: :view do
  context 'when rendering with valid data,' do
    context 'with a logged-in user without an associated swimmer,' do
      subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

      let(:current_user) { FactoryBot.create(:user) }

      before do
        expect(current_user.swimmer).to be nil
        sign_in(current_user)
        allow(view).to receive(:current_user).and_return(current_user)
        assign(:swimmer, nil)
        assign(:current_user_is_manager, false)
        render
      end

      it 'includes the section title' do
        expect(parsed_node.at_css('section#my-dashboard-title h3')).to be_present
        expect(parsed_node.at_css('section#my-dashboard-title h3').text).to include(current_user.description)
      end

      it 'renders a shortcut link to edit the swimmer association' do
        expect(parsed_node.at_css('#go-to-edit-swimmer-association a#associate-swimmer')).to be_present
        expect(parsed_node.at_css('a#associate-swimmer').attributes['href'].value)
          .to eq(edit_user_registration_path(anchor: 'swimmer-binding-help'))
        expect(parsed_node.at_css('a#associate-swimmer').text)
          .to include(t('home.my.associate_to_a_swimmer', user_name: current_user.name.titleize))
      end

      it_behaves_like('/home/dashboard rendered view')
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'with a logged-in user associated to a swimmer,' do
      subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

      let(:current_user) { GogglesDb::User.find([1, 2, 4].sample) }

      before do
        expect(current_user).to be_a(GogglesDb::User).and be_valid
        expect(current_user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        sign_in(current_user)
        allow(view).to receive(:current_user).and_return(current_user)
        assign(:swimmer, current_user.swimmer)
        assign(:current_user_is_manager, false)
        render
      end

      it 'includes the section title' do
        expect(parsed_node.at_css('section#my-dashboard-title h3')).to be_present
        expect(parsed_node.at_css('section#my-dashboard-title h3').text).to include(current_user.swimmer.complete_name)
      end

      it_behaves_like('/home/dashboard rendered view')

      it "includes the 'swimmer radiography' link" do
        expect(parsed_node.at_css('#dashboard-btns a#btn-my-radiography')).to be_present
        expect(parsed_node.at_css('#dashboard-btns a#btn-my-radiography').attributes['href'].value).to eq(swimmer_show_path(id: current_user&.swimmer_id))
      end

      xit "includes the 'swimmer statistics' link" do
        expect(parsed_node.at_css('#dashboard-btns a#btn-my-stats')).to be_present
        expect(parsed_node.at_css('#dashboard-btns a#btn-my-stats').attributes['href'].value).to eq('')
      end

      context 'when the current user is also a team manager,' do
        before { assign(:current_user_is_manager, true) }

        xit "includes the 'plan a meeting' link" do
          expect(parsed_node.at_css('#dashboard-btns a#btn-plan-meeting')).to be_present
          expect(parsed_node.at_css('#dashboard-btns a#btn-plan-meeting').attributes['href'].value).to eq('')
        end

        xit "includes the 'team reservation' link" do
          expect(parsed_node.at_css('#dashboard-btns a#btn-team-reservations')).to be_present
          expect(parsed_node.at_css('#dashboard-btns a#btn-team-reservations').attributes['href'].value).to eq('')
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
