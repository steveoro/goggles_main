# frozen_string_literal: true

require 'rails_helper'
require 'version'

RSpec.describe 'goggles/_main_footer.html.haml', type: :view do
  before(:each) { render }

  it 'shows the link to #contact_us' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('contact_us.title')))
    expect(rendered).to include(home_contact_us_path)
  end
  it 'shows the link to the privacy policy' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('home.privacy_policy.title')))
    expect(rendered).to include(home_privacy_policy_path)
  end
  it 'shows the link to #about_us' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('home.about_us')))
    expect(rendered).to include(home_about_us_path)
  end
  it 'shows the link to #about_this' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('home.about_this')))
    expect(rendered).to include(home_about_this_path)
  end
  it 'shows the social links' do
    expect(rendered).to include('https://www.facebook.com/MasterGoggles')
    expect(rendered).to include('https://www.linkedin.com/in/fasar/')
    expect(rendered).to include('https://twitter.com/master_goggles')
  end
  it 'shows the copyright notice' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('home.copyright_notice')))
  end
  it 'shows the current framework version' do
    expect(rendered).to include(Version::FULL)
  end
end
