# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'goggles/_main_navbar.html.haml' do
  let(:navbar_content) { Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul') }

  shared_examples_for 'main_navbar generic features' do
    it 'includes the #loading-indicator (hidden by default)' do
      expect(rendered).to match(/id=['"]loading-indicator['"]/)
      # Parse with Nokogiri & verify that the node is indeed invisible (CSS class 'd-none'):
      node = Nokogiri::HTML.fragment(rendered).at_css('#loading-indicator')
      expect(node.classes).to include('d-none')
    end

    it 'includes the clickable app name which redirects to the root_path' do
      node = Nokogiri::HTML.fragment(rendered).at_css('nav a#link-root')
      expect(node).to be_present
      expect(node.attributes['href'].value).to include(root_path)
      expect(node.text).to include('Goggles')
    end

    it 'includes the #navbar-content' do
      expect(navbar_content).to be_present
    end

    it 'shows the compute FIN score command in the navbar' do
      expect(navbar_content.at_css('a#link-compute-score')).to be_present
      expect(navbar_content.at_css('a#link-compute-score').attributes['href'].value).to include(tools_fin_score_path)
      expect(
        navbar_content.at_css('a#link-compute-score').text
      ).to include(ERB::Util.html_escape(I18n.t('home.compute_fin_score')))
    end
  end

  shared_examples_for('main_navbar signed-in features') do
    it 'shows the account management link in the navbar' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul')
      expect(node).to be_present
      expect(node.at_css('li a#link-account')).to be_present
      expect(node.at_css('li a#link-account').attributes['href'].value).to include(edit_user_registration_path)
    end

    it 'shows the log-out link in the navbar' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul')
      expect(node).to be_present
      expect(node.at_css('li a#link-logout')).to be_present
      expect(node.at_css('li a#link-logout').attributes['href'].value).to include(destroy_user_session_path)
      expect(node.at_css('li a#link-logout').text).to include(ERB::Util.html_escape(I18n.t('home.log_out')))
    end

    it 'shows the link to the swimmer dashboard' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul')
      expect(node).to be_present
      expect(node.at_css('li a#link-dashboard')).to be_present
      expect(node.at_css('li a#link-dashboard').attributes['href'].value).to include(home_dashboard_path)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an anonymous user,' do
    before { render }

    it_behaves_like('main_navbar generic features')

    it 'shows the log-in link in the navbar' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul')
      expect(node).to be_present
      expect(node.at_css('li a#link-login')).to be_present
      expect(node.at_css('li a#link-login').attributes['href'].value).to include(new_user_session_path)
      expect(node.at_css('li a#link-login').text).to include(ERB::Util.html_escape(I18n.t('home.log_in')))
    end

    it 'shows the sign-up link in the navbar' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul')
      expect(node).to be_present
      expect(node.at_css('li a#link-signup')).to be_present
      expect(node.at_css('li a#link-signup').attributes['href'].value).to include(new_user_registration_path)
      expect(node.at_css('li a#link-signup').text).to include(ERB::Util.html_escape(I18n.t('home.sign_up')))
    end

    it 'does not show the link to the dashboard' do
      node = Nokogiri::HTML.fragment(rendered).at_css('#navbar-content ul')
      expect(node).to be_present
      expect(node.at_css('li a#link-dashboard')).not_to be_present
    end

    it 'does not show the chrono command in the navbar' do
      expect(navbar_content.at_css('a#link-chrono')).not_to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a logged-in generic user (with no special grants),' do
    before do
      user = FactoryBot.create(:user)
      # [Steve A.] Stub Devise controller helper method before rendering because
      #            view specs do not have the @controller variable set.
      #            Also, sign-in the user using the included integration test helpers:
      sign_in(user)
      allow(view).to receive_messages(user_signed_in?: true, current_user: user)
      render
    end

    it_behaves_like('main_navbar generic features')
    it_behaves_like('main_navbar signed-in features')

    it 'does not show the chrono command in the navbar' do
      expect(navbar_content.at_css('a#link-chrono')).not_to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a signed-in TeamManager user,' do
    before do
      user = GogglesDb::User.first(2).sample
      # [Steve A.] Stub Devise controller helper method before rendering because
      #            view specs do not have the @controller variable set.
      #            Also, sign-in the user using the included integration test helpers:
      sign_in(user)
      allow(view).to receive_messages(user_signed_in?: true, current_user: user)
      assign(:current_user_is_manager, true)
      render
    end

    it_behaves_like('main_navbar generic features')
    it_behaves_like('main_navbar signed-in features')

    it 'shows the chrono command in the navbar' do
      expect(navbar_content.at_css('a#link-chrono')).to be_present
      expect(navbar_content.at_css('a#link-chrono').attributes['href'].value).to include(chrono_index_path)
      expect(
        navbar_content.at_css('a#link-chrono').text
      ).to include(ERB::Util.html_escape(I18n.t('chrono.title')))
    end
  end
end
