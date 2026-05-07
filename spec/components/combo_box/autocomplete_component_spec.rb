# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::AutocompleteComponent, type: :component do
  include ActionView::Helpers::FormOptionsHelper

  context 'with static option values' do
    subject do
      render_inline(
        described_class.new(
          label: label_text,
          base_name: base_name,
          required: true,
          wrapper_class: wrapper_class,
          values: options_for_select(options)
        )
      )
    end

    let(:wrapper_class) { 'col-auto' }
    let(:base_name) { 'event_type' }
    let(:label_text) { I18n.t('meetings.event') }
    let(:options) { [['50 FREESTYLE', 1], ['100 FREESTYLE', 2]] }

    it 'renders the autocomplete lookup wrapper' do
      expect(subject.css(".#{wrapper_class}.autocomplete-lookup")).to be_present
      expect(subject.css(".#{wrapper_class}.autocomplete-lookup").attr('data-controller').value)
        .to eq('autocomplete-lookup')
    end

    it 'renders the hidden value fields' do
      expect(subject.css("input##{base_name}_id[type='hidden']")).to be_present
      expect(subject.css("input##{base_name}_label[type='hidden']")).to be_present
    end

    it 'renders the select target without Select2 compatibility classes' do
      expect(subject.css("select.autocomplete-lookup__select##{base_name}_select")).to be_present
      expect(subject.css("select.autocomplete-lookup__select##{base_name}_select.select2")).not_to be_present
      expect(subject.css("select##{base_name}_select").attr('data-autocomplete-lookup-target').value)
        .to eq('field')
    end

    it 'renders the supplied options' do
      expect(subject.css("select##{base_name}_select option").count).to eq(options.count)
    end

    it 'sets the required field flag' do
      expect(subject.css("select##{base_name}_select").attr('required')).to be_present
    end
  end

  context 'with API values enabled' do
    subject do
      render_inline(
        described_class.new(
          api_url: api_url,
          label: label_text,
          base_name: base_name,
          use_2_api: true,
          free_text: true
        )
      )
    end

    let(:api_url) { 'meetings' }
    let(:base_name) { 'meeting' }
    let(:label_text) { I18n.t('chrono.selector.meeting') }

    it 'renders the API controller values' do
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url-value').value)
        .to include(api_url)
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url2-value').value)
        .to end_with('/api/v3')
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-free-text-value').value)
        .to eq('true')
    end
  end
end
