# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'goggles/_main_navbar.html.haml', type: :view do
  shared_examples_for 'main_navbar generic features' do
    it 'includes the #loading-indicator (hidden by default)' do
      expect(rendered).to match(/id=['"]loading-indicator['"]/)
      # Parse with Nokogiri & verify that the node is indeed invisible (CSS class 'd-none'):
      node = Nokogiri::HTML.fragment(rendered).at_css('#loading-indicator')
      expect(node.classes).to include('d-none')
    end

    it 'includes the #navbar-content' do
      expect(rendered).to match(/id=['"]navbar-content['"]/)
    end

    it 'includes the clickable app name which redirects to the root_path' do
      expect(rendered).to include(root_path).and include('Goggles')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'for an anonymous user,' do
    # Stub Devise user helper method before rendering:
    before(:each) do
      allow(view).to receive(:user_signed_in?).and_return(false)
      render
    end

    it_behaves_like('main_navbar generic features')

    it 'shows the log-in link' do
      expect(rendered).to include(new_user_session_path)
      expect(rendered).to include(I18n.t('home.log_in'))
    end
    it 'shows the sign-up link' do
      expect(rendered).to include(new_user_registration_path)
      expect(rendered).to include(I18n.t('home.sign_up'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'for a logged-in user,' do
    # Stub Devise user helper method before rendering:
    before(:each) do
      allow(view).to receive(:user_signed_in?).and_return(true)
      render
    end

    it_behaves_like('main_navbar generic features')

    it 'shows the log-out link' do
      expect(rendered).to include(destroy_user_session_path)
      expect(rendered).to include(I18n.t('home.log_out'))
    end
  end
end
