# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Footer::SocialUrlsComponent, type: :component do
  context 'when the social media URLs are present in the settings,' do
    # (Default settings values will do just fine)
    subject { render_inline(described_class.new) }

    let(:social_urls) { GogglesDb::AppParameter.versioning_row.settings(:social_urls) }

    it 'renders the Facebook URL link' do
      rendered_button = subject.at_css('a#social-fb-link')
      expect(rendered_button).to be_present
      expect(rendered_button['href']).to eq(social_urls.facebook)
    end

    it 'renders the Linkedin URL link' do
      rendered_button = subject.at_css('a#social-linkedin-link')
      expect(rendered_button).to be_present
      expect(rendered_button['href']).to eq(social_urls.linkedin)
    end

    # (Link disabled for the time being)
    it 'does NOT render the Twitter URL link' do
      rendered_button = subject.at_css('a#social-twitter-link')
      expect(rendered_button).not_to be_present
      # expect(rendered_button['href']).to eq(social_urls.twitter)
    end
  end

  context 'when no social media URLs are defined in the settings,' do
    subject { render_inline(described_class.new).to_html }

    before do
      # Clear the social media URLs settings:
      settings_row = GogglesDb::AppParameter.versioning_row.settings(:social_urls)
      settings_row.facebook = settings_row.linkedin = settings_row.twitter = nil
      settings_row.save!
    end

    it_behaves_like('any subject that renders nothing')
  end
end
