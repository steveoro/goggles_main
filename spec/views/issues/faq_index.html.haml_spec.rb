# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'issues/faq_index.html.haml' do
  # Test basic/required content:
  context 'with a successful rendering,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before { render }

    it 'shows the section title' do
      expect(subject.at_css('section#issues-faq-title')).to be_present
      expect(subject.at_css('section#issues-faq-title h4').text.strip).to include(I18n.t('issues.faq_title'))
    end

    it 'shows the link to go back to the parent page' do
      expect(subject.at_css('section#issues-faq-title h4 a#back-to-parent')).to be_present
      expect(subject.at_css('section#issues-faq-title h4 a#back-to-parent').attr('href')).to eq(root_path)
    end

    %w[
      type1a type1b type1c type1d
      type2a type2b
      type3a type3b type3c
      type4
    ].each do |issue_code_name|
      it "has the expandable card for '#{issue_code_name}' issues" do
        expect(subject.at_css(".card .card-header#title-#{issue_code_name}")).to be_present
        expect(subject.at_css(".card .card-header#title-#{issue_code_name} h5").text.strip).to include(I18n.t("issues.#{issue_code_name}.label"))
        expect(subject.at_css(".card .collapse#body-#{issue_code_name} .card-body")).to be_present
      end
    end

    it 'shows the link to the generic contact-us form' do
      expect(subject.at_css('a#href-contact-us')).to be_present
      expect(subject.at_css('a#href-contact-us').attr('href')).to eq(home_contact_us_path)
    end
  end
end
