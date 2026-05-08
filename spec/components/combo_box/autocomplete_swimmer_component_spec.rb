# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::AutocompleteSwimmerComponent, type: :component do
  context 'with API setup and a default row,' do
    subject do
      expect(default_row).to be_a(GogglesDb::Swimmer).and be_valid
      render_inline(
        described_class.new(
          label_text,
          base_name,
          free_text: true,
          required: required_option,
          disabled: disabled_option,
          use_2_api: true,
          default_row:
        )
      )
    end

    let(:label_text) { I18n.t('swimmers.swimmer_with_layout') }
    let(:base_name) { 'swimmer' }
    let(:required_option) { true }
    let(:disabled_option) { false }
    let(:default_row) { GogglesDb::Swimmer.first(150).sample }
    let(:decorated_default_row) { SwimmerDecorator.decorate(default_row) }

    it 'renders the autocomplete lookup wrapper and controller' do
      expect(subject.css('.col-auto.autocomplete-lookup')).to be_present
      expect(subject.css('.autocomplete-lookup').attr('data-controller').value).to eq('autocomplete-lookup')
    end

    it 'sets primary and secondary API URLs' do
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url-value').value)
        .to include('swimmers')
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url2-value').value)
        .to end_with('/api/v3')
    end

    it 'renders hidden id/label fields with selected values' do
      expect(subject.css("input##{base_name}_id").attr('value').value).to eq(default_row.id.to_s)
      expect(subject.css("input##{base_name}_label").attr('value').value)
        .to eq(decorated_default_row.text_label)
    end

    it 'renders swimmer extra hidden fields with selected values' do
      expect(subject.css("input##{base_name}_complete_name").attr('value').value)
        .to eq(decorated_default_row.complete_name)
      expect(subject.css("input##{base_name}_first_name").attr('value').value)
        .to eq(decorated_default_row.first_name)
      expect(subject.css("input##{base_name}_last_name").attr('value').value)
        .to eq(decorated_default_row.last_name)
    end

    it 'renders the selected swimmer option' do
      expect(subject.css("select##{base_name}_select option").count).to eq(1)
      expect(subject.css("select##{base_name}_select option").text).to eq(decorated_default_row.text_label)
      expect(subject.css("select##{base_name}_select option").attr('selected')).to be_present
    end

    it 'renders year of birth and gender controls' do
      expect(subject.css("input##{base_name}_year_of_birth").attr('value').value)
        .to eq(default_row.year_of_birth.to_s)
      expect(subject.css('select#gender_type_id option[selected]').attr('value').value)
        .to eq(default_row.gender_type_id.to_s)
    end
  end
end
