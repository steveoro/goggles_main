# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::DbLookupComponent, type: :component do
  include ActionView::Helpers::FormOptionsHelper

  context 'with a prefixed lookup list of option values,' do
    subject do
      expect(category_types.count).to be_positive
      render_inline(
        described_class.new(
          nil,
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
          disabled: disabled_option,
          wrapper_class: wrapper_class, # customize CSS wrapper DIV
          values: options_from_collection_for_select(category_types, 'id', 'short_name')
        )
      )
    end

    let(:wrapper_class) { %w[my-class1 my-class2 my-class3].sample }
    let(:base_name) { 'category_type' }
    let(:label_text) { I18n.t('meetings.category') }
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:disabled_option) { ['true', 'false', nil].sample }
    let(:category_types) do
      GogglesDb::Season.for_season_type(GogglesDb::SeasonType.mas_fin)
                       .by_begin_date.first
                       .category_types
                       .individuals.by_age
    end

    it_behaves_like('ComboBox::DbLookupComponent common rendered result')

    it "doesn't have an associated API URL value" do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value'))
        .not_to be_present
    end

    it 'renders as many option tags for the input select as the specified values' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").count)
        .to eq(category_types.count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a single API-based lookup list,' do
    subject do
      expect(last_chosen_row).to be_a(GogglesDb::Team).and be_valid
      render_inline(
        described_class.new(
          api_url,
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
          disabled: disabled_option,
          wrapper_class: wrapper_class,
          values: options_from_collection_for_select([last_chosen_row], 'id', 'name', last_chosen_row.id)
        )
      )
    end

    let(:wrapper_class) { %w[my-class1 my-class2 my-class3].sample }
    let(:api_url) { 'teams' }
    let(:base_name) { 'team' }
    let(:label_text) { I18n.t('teams.team') }
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:disabled_option) { ['true', 'false', nil].sample }
    let(:last_chosen_row) { GogglesDb::Team.first(100).sample }

    it_behaves_like('ComboBox::DbLookupComponent common rendered result')

    it 'includes the associated API URL value' do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value')).to be_present
      # The actual API URL used will feature the full protocol/port URI, so we test for inclusion only:
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value').value).to include(api_url)
    end

    it 'does not include the associated API-2 URL value' do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url2-value')).not_to be_present
    end

    it 'renders the default option tag of the preselected item for the select' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").count).to eq(1)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").text)
        .to eq(last_chosen_row.name)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").attr('selected')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a dobule-API call setup,' do
    subject do
      expect(last_chosen_row).to be_a(GogglesDb::Meeting).and be_valid
      render_inline(
        described_class.new(
          api_url,
          label_text,
          base_name,
          free_text: free_text_option,
          use_2_api: true,
          required: required_option,
          disabled: disabled_option,
          wrapper_class: wrapper_class,
          values: options_from_collection_for_select([last_chosen_row], 'id', 'description', last_chosen_row.id)
        )
      )
    end

    let(:wrapper_class) { %w[my-class1 my-class2 my-class3].sample }
    let(:api_url) { 'meetings' }
    let(:base_name) { 'meeting' }
    let(:label_text) { I18n.t('chrono.selector.meeting') }
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:disabled_option) { ['true', 'false', nil].sample }
    let(:last_chosen_row) { GogglesDb::Meeting.first(100).sample }

    it_behaves_like('ComboBox::DbLookupComponent common rendered result')

    it 'includes the associated API URL value' do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value')).to be_present
      # The actual API URL used will feature the full protocol/port URI, so we test for inclusion only:
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value').value).to include(api_url)
    end

    it 'includes the associated API-2 URL value' do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url2-value')).to be_present
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url2-value').value)
        .to end_with('/api/v3') # The API URL2 must be "rooted"
    end

    it 'renders the default option tag of the preselected item for the select' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").count).to eq(1)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").text)
        .to eq(last_chosen_row.description)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").attr('selected')).to be_present
    end
  end
end
