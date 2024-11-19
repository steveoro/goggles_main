# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tools/fin_score.html.haml' do
  subject { Nokogiri::HTML.fragment(rendered) }

  before do
    @gender_types = GogglesDb::GenderType.first(2)
    @event_types = GogglesDb::EventType.all_eventable
    @pool_types = GogglesDb::PoolType.all
    # Get just the last FIN Season for which we have standard timings:
    @last_fin_season = GogglesDb::StandardTiming.includes(:season_type)
                                                .joins(:season_type)
                                                .where('seasons.season_type_id': GogglesDb::SeasonType::MAS_FIN_ID)
                                                .last.season
    @category_types = @last_fin_season.category_types
    render
  end

  it 'includes the title' do
    expect(subject.css('.main-content #fin-score-title h4').text).to include(I18n.t('tools.fin_score.title'))
  end

  it 'includes the main form for the parameter selection' do
    expect(subject.css('.main-content #frm-fin-score')).to be_present
  end

  it 'renders the EventType select component' do
    expect(subject.css('#frm-fin-score #event_type_select')).to be_present
  end

  it 'renders the PoolType select component' do
    expect(subject.css('#frm-fin-score #pool_type_select')).to be_present
  end

  it 'renders the hidden season_id form parameter' do
    expect(subject.css('#frm-fin-score input#season_id')).to be_present
    expect(subject.css('#frm-fin-score input#season_id').attr('type').value)
      .to eq('hidden')
  end

  it 'renders the standard timing container to display the category record time' do
    expect(subject.css('#frm-fin-score #standard-timing-label')).to be_present
  end

  it 'renders the CategoryType select component' do
    expect(subject.css('#frm-fin-score #category_type_select')).to be_present
  end

  it 'renders the GenderType select component' do
    expect(subject.css('#frm-fin-score #gender_type_id')).to be_present
  end

  it 'renders the Target Timing imput fields' do
    expect(subject.css('#frm-fin-score input#minutes')).to be_present
    expect(subject.css('#frm-fin-score input#seconds')).to be_present
    expect(subject.css('#frm-fin-score input#hundredths')).to be_present
  end

  it 'renders the Target Score imput field' do
    expect(subject.css('#frm-fin-score input#score')).to be_present
  end

  it 'renders the 2 submit buttons (1 for target timing & 1 for target score)' do
    expect(subject.css('#frm-fin-score .btn#btn-fin-score')).to be_present
    expect(subject.css('#frm-fin-score .btn#btn-fin-timing')).to be_present
  end
end
