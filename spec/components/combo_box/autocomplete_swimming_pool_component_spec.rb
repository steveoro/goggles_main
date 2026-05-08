# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::AutocompleteSwimmingPoolComponent, type: :component do
  context 'with a complete setup (including a default row),' do
    subject do
      expect(default_row).to be_a(GogglesDb::SwimmingPool).and be_valid
      expect(decorated_default_row).to be_a(SwimmingPoolDecorator).and be_valid

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

    let(:label_text) { I18n.t('meetings.dashboard.swimming_pool') }
    let(:base_name) { 'swimming_pool' }
    let(:required_option) { true }
    let(:disabled_option) { false }
    let(:default_row) { GogglesDb::SwimmingPool.first(50).sample }
    let(:decorated_default_row) { SwimmingPoolDecorator.decorate(default_row) }

    it 'renders the autocomplete lookup wrapper and controller' do
      expect(subject.css('.col-auto.autocomplete-lookup')).to be_present
      expect(subject.css('.autocomplete-lookup').attr('data-controller').value).to eq('autocomplete-lookup')
    end

    it 'sets primary and secondary API URLs' do
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url-value').value)
        .to include('swimming_pools')
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url2-value').value)
        .to end_with('/api/v3')
    end

    it 'renders hidden id/label fields with selected values' do
      expect(subject.css("input##{base_name}_id").attr('value').value).to eq(default_row.id.to_s)
      expect(subject.css("input##{base_name}_label").attr('value').value)
        .to eq("#{decorated_default_row.name} (#{decorated_default_row.nick_name})")
    end

    it 'renders swimming pool extra hidden fields with selected values' do
      expect(subject.css("input##{base_name}_name").attr('value').value).to eq(decorated_default_row.name)
      expect(subject.css("input##{base_name}_nick_name").attr('value').value)
        .to eq(decorated_default_row.nick_name)
      expect(subject.css("input##{base_name}_city_id").attr('value').value)
        .to eq(decorated_default_row.city_id.to_s)
      expect(subject.css("input##{base_name}_pool_type_id").attr('value').value)
        .to eq(decorated_default_row.pool_type_id.to_s)
    end

    it 'renders the selected swimming pool option' do
      expect(subject.css("select##{base_name}_select option").count).to eq(1)
      expect(subject.css("select##{base_name}_select option").text)
        .to eq(decorated_default_row.text_label)
      expect(subject.css("select##{base_name}_select option").attr('selected')).to be_present
    end
  end
end
