# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'chrono/new.html.haml', type: :view do
  # Min case:
  context "when there's no associated swimmer for the current_user and there aren't any previous stored choices," do
    before(:each) do
      @seasons = GogglesDb::Season.includes(:season_type).in_range(Date.today - 1.year, Date.today + 3.months)
      @pool_types = GogglesDb::PoolType.all
      @event_types = GogglesDb::EventType.all_eventable[0..9]
      @category_types = GogglesDb::Season.for_season_type(GogglesDb::SeasonType.mas_fin)
                                         .by_begin_date.last
                                         .category_types.limit(10)
      render
    end
    subject { Nokogiri::HTML.fragment(rendered) }

    it 'includes the reference to the StimulusJS SwitchController' do
      expect(subject.css('.main-content').attr('data-controller')).to be_present
      expect(subject.css('.main-content').attr('data-controller').value).to eq('switch')
    end
    it 'includes the title' do
      expect(subject.css('.main-content #chrono-new-title h4').text).to include(I18n.t('chrono.new.title'))
    end
    it 'includes the main form for the parameter selection' do
      expect(subject.css('.main-content #frm-chrono-new')).to be_present
    end
    it 'renders the XOR switch component' do
      expect(subject.css('#xor-meeting-workshop')).to be_present
    end
    it 'renders the hidden rec_type form parameter' do
      expect(subject.css('#frm-chrono-new input#rec_type')).to be_present
      expect(subject.css('#frm-chrono-new input#rec_type').attr('type').value)
        .to eq('hidden')
    end
    it 'renders the Season Select component' do
      expect(subject.css('#frm-chrono-new #season_select')).to be_present
    end
    it 'renders the Meeting Select component' do
      expect(subject.css('#frm-chrono-new #meeting_select')).to be_present
    end
    it 'renders the UserWorkshop Select component' do
      expect(subject.css('#frm-chrono-new #user_workshop_select')).to be_present
    end

    it 'renders the SwimmingPool Select component' do
      expect(subject.css('#frm-chrono-new #swimming_pool_select')).to be_present
    end
    it 'renders the PoolType Select component' do
      expect(subject.css('#frm-chrono-new #pool_type_select')).to be_present
    end
    it 'renders the Event date imput field' do
      expect(subject.css('#frm-chrono-new input#event_date')).to be_present
    end

    it 'renders the EventType Select component' do
      expect(subject.css('#frm-chrono-new #event_type_select')).to be_present
    end
    it 'renders the Team Select component' do
      expect(subject.css('#frm-chrono-new #team_select')).to be_present
    end
    it 'renders the Swimmer Select component' do
      expect(subject.css('#frm-chrono-new #swimmer_select')).to be_present
    end
    it 'renders the CategoryType Select component' do
      expect(subject.css('#frm-chrono-new #category_type_select')).to be_present
    end

    it 'renders the submit button' do
      expect(subject.css('#frm-chrono-new .btn#btn-rec-chrono')).to be_present
    end
  end
end
