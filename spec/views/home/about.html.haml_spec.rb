# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/about.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with data,' do
    before { render }

    it 'shows the #about section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#about')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('about.title'))
    end

    it 'shows the #how-does-it-work section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#how-does-it-work')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('how_does_it_work.title'))
    end

    it 'shows the #who-we-are section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#who-we-are')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('who_we_are.title'))
    end

    it 'shows the #contributing section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#contributing')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('contributing.title'))
    end

    it 'shows the #faq section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#faq')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('faq.title'))
    end

    it 'shows the #privacy-policy section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#privacy-policy')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('privacy_policy.title'))
    end

    it 'shows the #legal-terms section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('.row-fluid#legal-terms')
      expect(node).to be_present
      expect(node.text).to include(I18n.t('legal_terms.title'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
