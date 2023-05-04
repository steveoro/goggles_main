# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'issues/my_reports.html.haml' do
  shared_examples_for('My-Reports page with the common elements properly rendered') do
    it 'shows the page title with the breadcrumb component' do
      expect(parsed_node.at_css('section#myreports-title h4 #curr-title')).to be_present
      expect(parsed_node.at_css('section#myreports-title h4 #curr-title').text.strip).to include(I18n.t('issues.my_reports_title'))
    end

    it 'has the link to go back to the root page' do
      expect(parsed_node.at_css('section#myreports-title h4 a#back-to-parent')).to be_present
      expect(parsed_node.at_css('section#myreports-title h4 a#back-to-parent').text.strip).to include(I18n.t('home.issues'))
      expect(parsed_node.at_css('section#myreports-title h4 a#back-to-parent').attr('href')).to eq(root_path)
    end

    it 'renders the top tab page selector with the active tab label' do
      expect(parsed_node.at_css('section#tab-my-reports ul.nav.nav-tabs')).to be_present
      expect(parsed_node.at_css('section#tab-my-reports ul.nav.nav-tabs li.nav-item .nav-link.active')).to be_present
      expect(parsed_node.at_css('section#tab-my-reports ul.nav.nav-tabs li.nav-item .nav-link.active').text.strip)
        .to include(I18n.t('issues.my_reports_title'))
    end

    it 'includes the link to its companion page (Issues FAQ)' do
      expect(parsed_node.at_css('section#tab-my-reports li.nav-item a')).to be_present
      expect(parsed_node.at_css('section#tab-my-reports li.nav-item a').attr('href'))
        .to eq(issues_faq_index_path)
      expect(parsed_node.at_css('section#tab-my-reports li.nav-item a').text.strip)
        .to include(I18n.t('issues.faq_title'))
    end

    it 'has the link to go back to the root page' do
      expect(parsed_node.at_css('section#myreports-title h4 a#back-to-parent')).to be_present
      expect(parsed_node.at_css('section#myreports-title h4 a#back-to-parent').text.strip).to include(I18n.t('home.issues'))
      expect(parsed_node.at_css('section#myreports-title h4 a#back-to-parent').attr('href')).to eq(root_path)
    end

    it 'has the issues grid section' do
      expect(parsed_node.at_css('section#issues-grid')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  let(:current_user) { FactoryBot.create(:user) }
  let(:issue_factories) do
    %i[
      issue_type0 issue_type1a issue_type1b issue_type1b1
      issue_type2b1 issue_type3b issue_type3c issue_type4
    ]
  end

  before do
    expect(current_user).to be_a(GogglesDb::User).and be_valid
    sign_in(current_user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(current_user)
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the current user does not have any reported issues,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    before do
      expect(GogglesDb::Issue.for_user(current_user).count).to be_zero
      grid = IssuesGrid.new do |scope|
        scope.for_user(current_user).page(1).per(8)
      end
      assign(:grid, grid)
      render
    end

    it_behaves_like('My-Reports page with the common elements properly rendered')

    it 'renders the empty issues grid with the default empty table message' do
      expect(parsed_node.at_css('section#issues-grid').text&.strip).to include(I18n.t('datagrid.no_results'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the current user has some reported issues,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:grid_domain) do
      issue_factories.sample(3).each do |factory|
        FactoryBot.create_list(factory, 3, user: current_user)
      end
      GogglesDb::Issue.for_user(current_user)
    end

    before do
      expect(grid_domain.count).to be >= 9
      grid = IssuesGrid.new do |scope|
        scope.for_user(current_user).page(1).per(8)
      end
      assign(:grid, grid)
      render
    end

    it_behaves_like('My-Reports page with the common elements properly rendered')

    it 'shows the datagrid top row which includes the filter show button' do
      expect(parsed_node.at_css('.row#datagrid-top-row')).to be_present
      expect(parsed_node.at_css('#filter-show-btn')).to be_present
    end

    it 'includes the datagrid total and the pagination rows, both on top and bottom of the grid' do
      expect(parsed_node.at_css('#pagination-top')).to be_present
      expect(parsed_node.at_css('#datagrid-total')).to be_present
      expect(parsed_node.at_css('#pagination-bottom')).to be_present
    end

    it 'shows the first page with the issues rows inside the grid' do
      expect(subject.at_css('section#issues-grid table.table tbody tr')).to be_present
      expect(subject.css('section#issues-grid table.table tbody tr').count).to eq(8) # (due to pagination set as above)
    end

    describe 'the datagrid' do
      %w[code priority status destroy].each do |column_name|
        it "includes a '#{column_name}' column" do
          expect(subject.at_css("section#issues-grid table.table tbody tr td.#{column_name}")).to be_present
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
