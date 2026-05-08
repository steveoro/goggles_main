# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::AutocompleteCityComponent, type: :component do
  context 'with a complete setup (including a default row),' do
    subject do
      expect(default_row).to be_a(GogglesDb::City).and be_valid
      render_inline(
        described_class.new(free_text: free_text_option, required: required_option, default_row:)
      )
    end

    let(:free_text_option) { true }
    let(:required_option) { true }
    let(:default_row) { GogglesDb::City.first(100).sample }

    it 'renders the autocomplete lookup wrapper and controller' do
      expect(subject.css('.col-auto.autocomplete-lookup')).to be_present
      expect(subject.css('.autocomplete-lookup').attr('data-controller').value).to eq('autocomplete-lookup')
    end

    it 'sets the city API URL on the wrapper' do
      expect(subject.css('.autocomplete-lookup').attr('data-autocomplete-lookup-api-url-value').value)
        .to include('cities')
    end

    it 'renders hidden id/label fields prefilled with the selected city' do
      expect(subject.css('input#city_id').attr('value').value).to eq(default_row.id.to_s)
      expect(subject.css('input#city_label').attr('value').value).to eq(default_row.name)
    end

    it 'renders the default selected city option' do
      expect(subject.css('select#city_select option').count).to eq(1)
      expect(subject.css('select#city_select option').text).to eq(default_row.name)
      expect(subject.css('select#city_select option').attr('selected')).to be_present
    end

    it 'renders area and country code fields with default values' do
      expect(subject.css('input#city_area').attr('value').value).to eq(default_row.area)
      expect(subject.css('input#city_country_code').attr('value').value)
        .to eq(default_row.country_code || 'IT')
    end
  end
end
