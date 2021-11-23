# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'chrono/rec.html.haml', type: :view do
  # Min case:
  context 'even without the parameter adapter,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before { render }

    it 'includes the reference to the StimulusJS ChronoController' do
      expect(subject.css('.main-content').attr('data-controller')).to be_present
      expect(subject.css('.main-content').attr('data-controller').value).to eq('chrono')
    end

    it 'includes the title' do
      expect(subject.css('.main-content #chrono-rec-title h4').text).to include(I18n.t('chrono.rec.title'))
    end

    it 'includes the header' do
      expect(subject.css('.main-content #rec-header')).to be_present
    end

    it 'includes the timer with its reference to the ChronoController' do
      expect(subject.css('.main-content #timer-container')).to be_present
      expect(subject.css('.main-content #timer-container #timer-digits')).to be_present
      expect(subject.css('.main-content #timer-container #timer-digits').attr('data-chrono-target')).to be_present
      expect(subject.css('.main-content #timer-container #timer-digits').attr('data-chrono-target').value).to eq('timer')
    end

    it 'includes the reset button' do
      expect(subject.css('.main-content #timer-btn-reset')).to be_present
    end

    it 'includes the start/stop button' do
      expect(subject.css('.main-content #timer-btn-switch')).to be_present
    end

    it 'includes the lap button' do
      expect(subject.css('.main-content #timer-btn-lap')).to be_present
    end

    it 'includes the lap grid with its reference to the ChronoController' do
      expect(subject.css('.main-content #laps-grid')).to be_present
      expect(subject.css('.main-content #laps-grid').attr('data-chrono-target')).to be_present
      expect(subject.css('.main-content #laps-grid').attr('data-chrono-target').value).to eq('lapsGrid')
    end

    it 'includes the form for the grid data post' do
      expect(subject.css('.main-content #frm-chrono-rec')).to be_present
    end

    it 'renders the hidden header form parameter' do
      expect(subject.css('#frm-chrono-rec input#json_header')).to be_present
      expect(subject.css('#frm-chrono-rec input#json_header').attr('type').value)
        .to eq('hidden')
    end

    it 'renders the hidden payload form parameter' do
      expect(subject.css('#frm-chrono-rec input#json_payload')).to be_present
      expect(subject.css('#frm-chrono-rec input#json_payload').attr('type').value)
        .to eq('hidden')
    end

    it 'renders the submit button' do
      expect(subject.css('#frm-chrono-rec .btn#timer-btn-save')).to be_present
    end
  end
end
