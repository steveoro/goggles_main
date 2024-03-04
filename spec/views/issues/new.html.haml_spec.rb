# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'issues/new.html.haml' do
  let(:current_user) { GogglesDb::User.last(50).sample }

  context "when the issue type is '0' ('promote to team manager')," do
    subject { Nokogiri::HTML.fragment(rendered) }

    before do
      assign(:type, '0')
      assign(:issue_title, I18n.t('issues.type0.title'))
      assign(:seasons, fixture_seasons)
      render
    end

    let(:fixture_seasons) { GogglesDb::Season.last(3) }

    it 'shows the page title' do
      expect(subject.at_css('#issue-title h4')).to be_present
      expect(subject.at_css('#issue-title h4').text.strip).to include(I18n.t('issues.type0.title'))
    end

    it 'includes the type0 form' do
      expect(subject.at_css('form#frm-type0')).to be_present
    end

    it 'has the DB-lookup component to select a Team' do
      expect(subject.at_css('form#frm-type0 select#team_select')).to be_present
    end

    it 'has a checkbox for each specified season' do
      fixture_seasons.each_with_index do |season, index|
        expect(subject.at_css("input#season_#{index}")).to be_present
        expect(subject.at_css("input#season_#{index}").attr('value')).to eq(season.id.to_s)
      end
    end

    it 'has a submit button' do
      expect(subject.at_css('form#frm-type0 #issues-type0-post-btn')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when the issue type is '1b' ('missing result from meeting')," do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:can_manage) { [true, false].sample } # for brevity, one test for both cases depending on value

    before do
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      # (The view uses current_user but it doesn't matter if current_user.swimmer is nil)
      assign(:type, '1b')
      assign(:issue_title, I18n.t('issues.type1b.form.title'))
      assign(:parent_meeting, GogglesDb::Meeting.last(10).sample)
      assign(:swimmers, GogglesDb::Swimmer.first(100).sample(5))
      assign(:can_manage, can_manage)
      allow(view).to receive(:current_user).and_return(current_user)
      render
    end

    it 'shows the page title' do
      expect(subject.at_css('#issue-title h4')).to be_present
      expect(subject.at_css('#issue-title h4').text.strip).to include(I18n.t('issues.type1b.form.title'))
    end

    it 'includes the type1b form' do
      expect(subject.at_css('form#frm-type1b')).to be_present
    end

    it 'has the EventType DB-lookup component' do
      expect(subject.at_css('form#frm-type1b select#event_type_select')).to be_present
    end

    it 'has the DB-Swimmer lookup component for selecting a swimmer' do
      expect(subject.at_css('form#frm-type1b select#swimmer_select')).to be_present
    end

    # [20240201] Currently, the "TeamManager grant limit" for reporting missing results has been lifted
    # it 'enables (or disables) the DB-Swimmer lookup depending if the current user has management grants (or not)' do
    it 'has the DB-Swimmer lookup always enabled regardless if the current user has management grants (or not)' do
      expect(subject.at_css('form#frm-type1b select#swimmer_select').attr('disabled')).not_to be_present
      # if can_manage
      #   expect(subject.at_css('form#frm-type1b select#swimmer_select').attr('disabled')).not_to be_present
      # else
      #   expect(subject.at_css('form#frm-type1b select#swimmer_select').attr('disabled')).to be_present
      # end
    end

    it 'has the input field for the minutes' do
      expect(subject.at_css('form#frm-type1b input#minutes')).to be_present
    end

    it 'has the input field for the seconds' do
      expect(subject.at_css('form#frm-type1b input#seconds')).to be_present
    end

    it 'has the input field for the hundredths' do
      expect(subject.at_css('form#frm-type1b input#hundredths')).to be_present
    end

    it 'has a submit button' do
      expect(subject.at_css('form#frm-type1b #issues-type1b-post-btn')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when the issue type is '1b1' ('wrong result in meeting')," do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:result_row) { GogglesDb::MeetingIndividualResult.last(250).sample }

    before do
      assign(:type, '1b1')
      assign(:issue_title, I18n.t('issues.type1b1.form.title'))
      assign(:result_row, result_row)
      render
    end

    it 'shows the page title' do
      expect(subject.at_css('#issue-title h4')).to be_present
      expect(subject.at_css('#issue-title h4').text.strip).to include(I18n.t('issues.type1b1.form.title'))
    end

    it 'renders the top tab page selector with the active tab label' do
      expect(subject.at_css('section#tab-form-1b1 ul.nav.nav-tabs')).to be_present
      expect(subject.at_css('section#tab-form-1b1 ul.nav.nav-tabs li.nav-item .nav-link.active')).to be_present
      expect(subject.at_css('section#tab-form-1b1 ul.nav.nav-tabs li.nav-item .nav-link.active').text.strip)
        .to include(I18n.t('issues.type1b1.form.tab_label'))
    end

    it 'includes the link to its companion issue type' do
      expect(subject.at_css('section#tab-form-1b1 li.nav-item a')).to be_present
      expect(subject.at_css('section#tab-form-1b1 li.nav-item a').attr('href'))
        .to eq(issues_new_type2b1_path(result_id: result_row.id, result_class: result_row.class.name))
      expect(subject.at_css('section#tab-form-1b1 li.nav-item a').text.strip)
        .to include(I18n.t('issues.type2b1.form.tab_label'))
    end

    it 'includes the form_type1b1 form' do
      expect(subject.at_css('form#frm-type1b1')).to be_present
    end

    it 'has the input field for the minutes' do
      expect(subject.at_css('form#frm-type1b1 input#minutes')).to be_present
    end

    it 'has the input field for the seconds' do
      expect(subject.at_css('form#frm-type1b1 input#seconds')).to be_present
    end

    it 'has the input field for the hundredths' do
      expect(subject.at_css('form#frm-type1b1 input#hundredths')).to be_present
    end

    it 'has a submit button' do
      expect(subject.at_css('form#frm-type1b1 #issues-type1b1-post-btn')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when the issue type is '2b1' ('wrong team, swimmer or meeting')," do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:result_row) do
      [
        GogglesDb::MeetingIndividualResult.last(250).sample,
        GogglesDb::UserResult.last(250).sample
      ].sample
    end

    before do
      assign(:type, '2b1')
      assign(:issue_title, I18n.t('issues.type1b1.form.title'))
      assign(:result_row, result_row)
      render
    end

    it 'shows the page title (same as issue 1b1)' do
      expect(subject.at_css('#issue-title h4')).to be_present
      expect(subject.at_css('#issue-title h4').text.strip).to include(I18n.t('issues.type1b1.form.title'))
    end

    it 'renders the top tab page selector with the active tab label' do
      expect(subject.at_css('section#tab-form-2b1 ul.nav.nav-tabs')).to be_present
      expect(subject.at_css('section#tab-form-2b1 ul.nav.nav-tabs li.nav-item .nav-link.active')).to be_present
      expect(subject.at_css('section#tab-form-2b1 ul.nav.nav-tabs li.nav-item .nav-link.active').text.strip)
        .to include(I18n.t('issues.type2b1.form.tab_label'))
    end

    it 'includes the link to its companion issue type' do
      expect(subject.at_css('section#tab-form-2b1 li.nav-item a')).to be_present
      expect(subject.at_css('section#tab-form-2b1 li.nav-item a').attr('href'))
        .to eq(issues_new_type1b1_path(result_id: result_row.id, result_class: result_row.class.name))
      expect(subject.at_css('section#tab-form-2b1 li.nav-item a').text.strip)
        .to include(I18n.t('issues.type1b1.form.tab_label'))
    end

    it 'includes the form type2b1 form' do
      expect(subject.at_css('form#frm-type2b1')).to be_present
    end

    it 'has a checkbox to select if the meeting is wrong' do
      expect(subject.at_css('input#wrong_meeting')).to be_present
    end

    it 'has a checkbox to select if the swimmer is wrong' do
      expect(subject.at_css('input#wrong_swimmer')).to be_present
    end

    it 'has a checkbox to select if the team is wrong (if the parent result supports the link to the team)' do
      expect(subject.at_css('input#wrong_team')).to be_present if result_row.respond_to?(:team)
    end

    it 'has the input field for the minutes' do
      expect(subject.at_css('form#frm-type2b1 input#minutes')).to be_present
    end

    it 'has the input field for the seconds' do
      expect(subject.at_css('form#frm-type2b1 input#seconds')).to be_present
    end

    it 'has the input field for the hundredths' do
      expect(subject.at_css('form#frm-type2b1 input#hundredths')).to be_present
    end

    it 'has a submit button' do
      expect(subject.at_css('form#frm-type2b1 #issues-type2b1-post-btn')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when the issue is of an unsupported type,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before do
      assign(:type, '')
      render
    end

    it 'does not render any form' do
      expect(subject.at_css('form')).not_to be_present
    end

    it 'shows an invalid type warning in the main content body' do
      expect(subject.at_css('.main-content .container b').text.strip).to include(I18n.t('issues.invalid_type'))
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
