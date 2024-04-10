# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tools/delta_timings.html.haml' do
  subject { Nokogiri::HTML.fragment(rendered) }

  before { render }

  it 'includes the title' do
    expect(subject.css('.main-content #deltas-title h4').text).to include(I18n.t('tools.delta_timings.title'))
  end

  it 'includes the main form for the parameters' do
    expect(subject.css('.main-content #frm-deltas')).to be_present
  end

  it 'includes 16 input rows, each one with its input fields and destination delta-t div' do
    16.times do |index|
      input_row = subject.css("tr#delta-row-#{index}")
      expect(input_row).to be_present
      expect(input_row.css("input#m_#{index}")).to be_present
      expect(input_row.css("input#s_#{index}")).to be_present
      expect(input_row.css("input#h_#{index}")).to be_present
      expect(input_row.css("#delta-#{index}")).to be_present
    end
  end

  it 'renders the submit button' do
    expect(subject.css('#frm-deltas .btn#btn-compute-deltas')).to be_present
  end

  it 'renders the output TXT/CSV button' do
    expect(subject.css('#frm-deltas .btn#btn-output-deltas')).to be_present
  end
end
