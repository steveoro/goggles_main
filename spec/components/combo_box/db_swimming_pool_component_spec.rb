# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::DbSwimmingPoolComponent, type: :component do
  include ActionView::Helpers::FormOptionsHelper

  # Testing only the most complete option setup outcome:
  context 'with a complete setup (including a default row),' do
    # Default values for the rendered sub-component: (needed by the shared examples)
    let(:wrapper_class) { 'col-auto' }
    let(:api_url) { 'swimming_pools' }
    let(:label_text) { I18n.t('meetings.dashboard.swimming_pool') }
    let(:base_name) { 'swimming_pool' }

    # Actual options:
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:default_row) { GogglesDb::SwimmingPool.first(50).sample }
    let(:decorated_default_row) { SwimmingPoolDecorator.decorate(default_row) }

    subject do
      expect(default_row).to be_a(GogglesDb::SwimmingPool).and be_valid
      expect(decorated_default_row).to be_a(SwimmingPoolDecorator).and be_valid

      render_inline(
        described_class.new(
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
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

    it 'renders the hidden name field' do
      expect(subject.css("input##{base_name}_name")).to be_present
      expect(subject.css("input##{base_name}_name").attr('type').value)
        .to eq('hidden')
    end
    it 'sets the hidden name field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_name").attr('value').value)
        .to eq(decorated_default_row&.name)
    end

    it 'renders the hidden nick_name field' do
      expect(subject.css("input##{base_name}_nick_name")).to be_present
      expect(subject.css("input##{base_name}_nick_name").attr('type').value)
        .to eq('hidden')
    end
    it 'sets the hidden nick_name field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_nick_name").attr('value').value)
        .to eq(decorated_default_row&.nick_name)
    end

    it 'renders the hidden city_id field' do
      expect(subject.css("input##{base_name}_city_id")).to be_present
      expect(subject.css("input##{base_name}_city_id").attr('type').value)
        .to eq('hidden')
    end
    it 'sets the hidden city_id field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_city_id").attr('value').value)
        .to eq(decorated_default_row&.city_id.to_s)
    end

    it 'renders the hidden pool_type_id field' do
      expect(subject.css("input##{base_name}_pool_type_id")).to be_present
      expect(subject.css("input##{base_name}_pool_type_id").attr('type').value)
        .to eq('hidden')
    end
    it 'sets the hidden pool_type_id field with the value from the default row (when present)' do
      expect(subject.css("input##{base_name}_pool_type_id").attr('value').value)
        .to eq(decorated_default_row&.pool_type_id.to_s)
    end
  end
end
