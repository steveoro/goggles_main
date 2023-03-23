# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'issues/my_reports.html.haml', type: :view do
  let(:current_user) { GogglesDb::User.last(50).sample }

  shared_examples_for('My-Reports page with the common elements properly rendered') do
    it 'shows the page title with the breadcrumb component' do
      expect(subject.at_css('section#myreports-title h4 #curr-title')).to be_present
      expect(subject.at_css('section#myreports-title h4 #curr-title').text.strip).to include(I18n.t('issues.my_reports_title'))
    end

    it 'has the link to go back to the root page' do
      expect(subject.at_css('section#myreports-title h4 a#back-to-parent')).to be_present
      expect(subject.at_css('section#myreports-title h4 a#back-to-parent').text.strip).to include(I18n.t('home.issues'))
      expect(subject.at_css('section#myreports-title h4 a#back-to-parent').attr('href')).to eq(root_path)
    end

    it 'renders the top tab page selector with the active tab label' do
      expect(subject.at_css('section#tab-my-reports ul.nav.nav-tabs')).to be_present
      expect(subject.at_css('section#tab-my-reports ul.nav.nav-tabs li.nav-item .nav-link.active')).to be_present
      expect(subject.at_css('section#tab-my-reports ul.nav.nav-tabs li.nav-item .nav-link.active').text.strip)
        .to include(I18n.t('issues.my_reports_title'))
    end

    it 'includes the link to its companion page (Issues FAQ)' do
      expect(subject.at_css('section#tab-my-reports li.nav-item a')).to be_present
      expect(subject.at_css('section#tab-my-reports li.nav-item a').attr('href'))
        .to eq(issues_faq_index_path)
      expect(subject.at_css('section#tab-my-reports li.nav-item a').text.strip)
        .to include(I18n.t('issues.faq_title'))
    end

    it 'has the link to go back to the root page' do
      expect(subject.at_css('section#myreports-title h4 a#back-to-parent')).to be_present
      expect(subject.at_css('section#myreports-title h4 a#back-to-parent').text.strip).to include(I18n.t('home.issues'))
      expect(subject.at_css('section#myreports-title h4 a#back-to-parent').attr('href')).to eq(root_path)
    end

    it 'has the issues grid section' do
      expect(subject.at_css('section#issues-grid')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the current user does not have any reported issues,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before { render }

    it_behaves_like('My-Reports page with the common elements properly rendered')

    it "renders the empty issues grid with a 'no issues found' message" do
      expect(subject.at_css('section#issues-grid p').text.strip).to include(I18n.t('issues.no_issues_found'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the current user has some reported issues,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before { render }

    it_behaves_like('My-Reports page with the common elements properly rendered')

    xit 'shows the issues grid with the existing issues rows' do
      # TODO
    end

    # TODO
  end
  #-- -------------------------------------------------------------------------
  #++
end
