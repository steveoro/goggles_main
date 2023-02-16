# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::DbCityComponent, type: :component do
  include ActionView::Helpers::FormOptionsHelper

  # Testing only the most complete option setup outcome:
  context 'with a complete setup (including a default row),' do
    # Default values for the rendered sub-component: (needed by the shared examples)
    subject do
      expect(default_row).to be_a(GogglesDb::City).and be_valid
      render_inline(
        described_class.new(free_text: free_text_option, required: required_option, default_row: default_row)
      )
    end

    let(:wrapper_class) { 'col-auto' }
    let(:api_url) { 'cities' }
    let(:label_text) { I18n.t('swimming_pools.city') }
    let(:base_name) { 'city' }

    # Actual options:
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:disabled_option) { false } # (no support for the 'disabled' option in DbCityComponent at the moment)
    let(:default_row) { GogglesDb::City.first(100).sample }

    it_behaves_like('ComboBox::DbLookupComponent common rendered result')

    it 'includes the associated API URL value' do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value')).to be_present
      # The actual API URL used will feature the full protocol/port URI, so we test for inclusion only:
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value').value).to include(api_url)
    end

    it 'renders the default option tag of the preselected item for the select' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").count).to eq(1)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").text)
        .to eq(default_row.name)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").attr('selected')).to be_present
    end

    it 'renders the city area label' do
      expect(subject.css('label[for="city_area"]')).to be_present
      expect(subject.css('label[for="city_area"]').text).to eq(I18n.t('swimming_pools.area_code'))
    end

    it 'renders the city area text input with the default value from the specified row (when present)' do
      expect(subject.css('input#city_area')).to be_present
      expect(subject.css('input#city_area').attr('value').value).to eq(default_row&.area)
    end

    it 'renders the city country code label' do
      expect(subject.css('label[for="city_country_code"]')).to be_present
      expect(subject.css('label[for="city_country_code"]').text).to eq(I18n.t('swimming_pools.country_code'))
    end

    it "renders the city country code text input with the default value from the specified row (with an 'IT' default)" do
      expect(subject.css('input#city_country_code')).to be_present
      expect(subject.css('input#city_country_code').attr('value').value)
        .to eq(default_row&.country_code || 'IT')
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
