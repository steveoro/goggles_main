# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Footer::MainComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject { render_inline(described_class.new).to_html }
  let(:rendered_footer) { Nokogiri::HTML.fragment(subject).at_css('footer') }

  it 'renders the footer section' do
    expect(rendered_footer).to be_present
  end

  it 'includes the locale toggle switch link' do
    node = rendered_footer.at_css('a#href-locale-switch')
    expect(node).to be_present
    expect(node['href']).to include(home_index_path.to_s)
  end

  it 'includes the "contact us" link' do
    expect(rendered_footer.text).to include(I18n.t('contact_us.title'))
    expect(rendered_footer.at_css('a#href-contact-us')['href']).to include(home_contact_us_path.to_s)
  end
  it 'includes the "privacy policy" link' do
    expect(rendered_footer.text).to include(I18n.t('home.privacy_policy.title'))
    expect(rendered_footer.at_css('a#href-privacy-policy')['href']).to include(home_about_path(anchor: 'privacy-policy'))
  end
  it 'includes the "about" link' do
    expect(rendered_footer.text).to include(I18n.t('home.about_this'))
    expect(rendered_footer.at_css('a#href-about')['href']).to include(home_about_path)
  end

  it 'includes the copyright notice' do
    expect(rendered_footer.text).to include(I18n.t('home.copyright_notice'))
  end
  it 'includes the current version' do
    expect(rendered_footer.text).to include(Version::FULL)
  end
end
