# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::DbSwimmerComponent, type: :component do
  include ActionView::Helpers::FormOptionsHelper

  let(:wrapper_class) { 'col-auto' }
  let(:api_url) { 'swimmers' }
  let(:label_text) { I18n.t('swimmers.swimmer_with_layout') }
  let(:base_name) { 'swimmer' }

  # Actual options:
  let(:free_text_option) { ['true', 'false', nil].sample }
  let(:required_option) { ['true', 'false', nil].sample }
  let(:disabled_option) { ['true', 'false', nil].sample }
  let(:default_row) { GogglesDb::Swimmer.first(150).sample }
  let(:decorated_default_row) { SwimmerDecorator.decorate(default_row) }
  let(:values) { GogglesDb::Swimmer.first(250).sample(5) }

  before do
    expect(default_row).to be_a(GogglesDb::Swimmer).and be_valid
    expect(decorated_default_row).to be_a(SwimmerDecorator).and be_valid
    expect(values).to all be_a(GogglesDb::Swimmer).and be_valid
  end

  context 'with a prefixed lookup list of option values,' do
    subject do
      render_inline(
        described_class.new(
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
          disabled: disabled_option,
          wrapper_class: wrapper_class, # customize CSS wrapper DIV
          values: values
        )
      )
    end

    it_behaves_like('ComboBox::DbLookupComponent common rendered result')

    it "doesn't have an associated API URL value" do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value'))
        .not_to be_present
    end

    it 'renders as many option tags for the input select as the specified values' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").count)
        .to eq(values.count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a full API setup (including a default row, with dual-API enabled),' do
    # Default values for the rendered sub-component: (needed by the shared examples)
    subject do
      render_inline(
        described_class.new(
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
          disabled: disabled_option,
          use_2_api: true,
          default_row: default_row
        )
      )
    end

    it_behaves_like('ComboBox::DbLookupComponent with double-API call enabled')

    it 'renders the default option tag of the preselected item for the select' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").count).to eq(1)
    end

    it 'pre-selects the specified option' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").text)
        .to eq(decorated_default_row.text_label)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").attr('selected')).to be_present
    end

    it 'sets the hidden id field with the value from the default row' do
      expect(subject.css("input##{base_name}_id").attr('value').value)
        .to eq(default_row.id.to_s)
    end

    it 'sets the hidden label field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_label").attr('value').value)
        .to eq(decorated_default_row.text_label)
    end

    it 'renders the hidden complete_name field' do
      expect(subject.css("input##{base_name}_complete_name")).to be_present
      expect(subject.css("input##{base_name}_complete_name").attr('type').value)
        .to eq('hidden')
    end

    it 'sets the hidden complete_name field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_complete_name").attr('value').value)
        .to eq(decorated_default_row&.complete_name)
    end

    it 'renders the hidden first_name field' do
      expect(subject.css("input##{base_name}_first_name")).to be_present
      expect(subject.css("input##{base_name}_first_name").attr('type').value)
        .to eq('hidden')
    end

    it 'sets the hidden first_name field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_first_name").attr('value').value)
        .to eq(decorated_default_row&.first_name)
    end

    it 'renders the hidden last_name field' do
      expect(subject.css("input##{base_name}_last_name")).to be_present
      expect(subject.css("input##{base_name}_last_name").attr('type').value)
        .to eq('hidden')
    end

    it 'sets the hidden last_name field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_last_name").attr('value').value)
        .to eq(decorated_default_row&.last_name)
    end

    it 'renders the year_of_birth label' do
      expect(subject.css("label[for=\"#{base_name}_year_of_birth\"]")).to be_present
      expect(subject.css("label[for=\"#{base_name}_year_of_birth\"]").text).to eq(I18n.t('swimmers.age_class'))
    end

    it 'renders the year_of_birth input field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_year_of_birth")).to be_present
      expect(subject.css("input##{base_name}_year_of_birth").attr('value').value)
        .to eq(default_row&.year_of_birth.to_s)
    end

    it 'renders the gender_type label' do
      expect(subject.css('label[for="gender_type_id"]')).to be_present
      expect(subject.css('label[for="gender_type_id"]').text).to eq(I18n.t('swimmers.sex'))
    end

    it 'renders the gender_type select input with the value from the default row (when present)' do
      expect(subject.css('select#gender_type_id')).to be_present
      expect(subject.css('select#gender_type_id option[selected]').attr('value').value)
        .to eq(default_row&.gender_type_id.to_s)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
