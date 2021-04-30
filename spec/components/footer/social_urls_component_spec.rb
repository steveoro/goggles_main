# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Footer::SocialUrlsComponent, type: :component do
  context 'when the social media URLs are present in the settings,' do
    # (Default settings values will do just fine)
    subject { render_inline(described_class.new).to_html }

    it 'renders the Facebook URL link' do
      node = Nokogiri::HTML.fragment(subject).at_css('#social-fb-link')
      expect(node).to be_present
    end
    it 'renders the Linkedin URL link' do
      node = Nokogiri::HTML.fragment(subject).at_css('#social-linkedin-link')
      expect(node).to be_present
    end
    it 'renders the Twitter URL link' do
      node = Nokogiri::HTML.fragment(subject).at_css('#social-twitter-link')
      expect(node).to be_present
    end
  end

  context 'when no social media URLs are defined in the settings,' do
    before(:each) do
      # Clear the social media URLs settings:
      settings_row = GogglesDb::AppParameter.versioning_row.settings(:social_urls)
      settings_row.facebook = settings_row.linkedin = settings_row.twitter = nil
      settings_row.save!
    end
    subject { render_inline(described_class.new).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
