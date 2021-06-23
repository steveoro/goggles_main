# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboBox::DbLookupComponent, type: :component do
  include ActionView::Helpers::FormOptionsHelper

  # REQUIRES/ASSUMES:
  # - subject............: result from #render_inline (renders a Nokogiri::HTML.fragment)
  # - wrapper_class......: CSS class name for the wrapper DIV of the component
  # - free_text_option...: 'true' to enable the free-text input
  # - base_name..........: API/widget base name
  # - label_text.........: display label for the widget
  # - required_option....: 'true' to enable the required HTML attribute for the select input tag
  shared_examples_for 'ComboBox::DbLookupComponent common rendered result' do
    describe 'the wrapper DIV' do
      it 'has the customizable wrapper class' do
        expect(subject.css("div.#{wrapper_class}")).to be_present
      end
      it 'includes the reference to the StimulusJS LookupController' do
        expect(subject.css("div.#{wrapper_class}").attr('data-controller')).to be_present
        expect(subject.css("div.#{wrapper_class}").attr('data-controller').value).to eq('lookup')
      end
      it "sets the 'free-text' controller option accordingly (when set)" do
        if free_text_option
          expect(subject.css("div.#{wrapper_class}").attr('data-lookup-free-text-value'))
            .to be_present
          expect(subject.css("div.#{wrapper_class}").attr('data-lookup-free-text-value').value)
            .to eq(free_text_option)
        end
      end
      it "sets the 'base name' controller option" do
        expect(subject.css("div.#{wrapper_class}").attr('data-lookup-field-base-name-value'))
          .to be_present
        expect(subject.css("div.#{wrapper_class}").attr('data-lookup-field-base-name-value').value)
          .to eq(base_name)
      end
    end

    it 'renders the hidden ID input field' do
      expect(subject.css("div.#{wrapper_class} input##{base_name}_id")).to be_present
      expect(subject.css("div.#{wrapper_class} input##{base_name}_id").attr('type').value)
        .to eq('hidden')
    end
    it 'renders the hidden label input field (the text value of the currently chosen option)' do
      expect(subject.css("div.#{wrapper_class} input##{base_name}_label")).to be_present
      expect(subject.css("div.#{wrapper_class} input##{base_name}_label").attr('type').value)
        .to eq('hidden')
    end
    it 'renders the display label text' do
      expect(subject.css("div.#{wrapper_class} label[for=\"#{base_name}\"]")).to be_present
      expect(subject.css("div.#{wrapper_class} label[for=\"#{base_name}\"]").text).to eq(label_text)
    end

    it "renders the 'input presence' flag (which is red by default)" do
      expect(subject.css("div.#{wrapper_class} b##{base_name}-presence")).to be_present
      expect(subject.css("div.#{wrapper_class} b##{base_name}-presence").text).to eq('*')
      expect(subject.css("div.#{wrapper_class} b##{base_name}-presence").attr('class').value).to eq('text-danger')
    end

    it 'renders the Select input tag with the proper parameters for the LookupController' do
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select")).to be_present
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select").attr('data-lookup-target').value)
        .to eq('field')
    end

    it "sets the 'required' HTML field flag accordingly (when set)" do
      if required_option
        expect(subject.css("##{base_name}_select").attr('required')).to be_present
        expect(subject.css("##{base_name}_select").attr('required').value).to eq(required_option)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a prefixed lookup list of option values,' do
    let(:wrapper_class) { %w[my-class1 my-class2 my-class3].sample }
    let(:base_name) { 'category_type' }
    let(:label_text) { I18n.t('meetings.category') }
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:category_types) do
      GogglesDb::Season.for_season_type(GogglesDb::SeasonType.mas_fin)
                       .by_begin_date.first
                       .category_types
                       .individuals.by_age
    end

    subject do
      expect(category_types.count).to be_positive
      render_inline(
        described_class.new(
          nil,
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
          wrapper_class: wrapper_class, # customize CSS wrapper DIV
          values: options_from_collection_for_select(category_types, 'id', 'short_name')
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
        .to eq(category_types.count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a single API-based lookup list,' do
    let(:wrapper_class) { %w[my-class1 my-class2 my-class3].sample }
    let(:api_url) { 'teams' }
    let(:base_name) { 'team' }
    let(:label_text) { I18n.t('teams.team') }
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:last_chosen_row) { GogglesDb::Team.first(100).sample }

    subject do
      expect(last_chosen_row).to be_a(GogglesDb::Team).and be_valid
      render_inline(
        described_class.new(
          api_url,
          label_text,
          base_name,
          free_text: free_text_option,
          required: required_option,
          wrapper_class: wrapper_class,
          values: options_from_collection_for_select([last_chosen_row], 'id', 'name', last_chosen_row.id)
        )
      )
    end

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
        .to eq(last_chosen_row.name)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").attr('selected')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a double API call setup,' do
    let(:wrapper_class) { %w[my-class1 my-class2 my-class3].sample }
    let(:api_url) { 'meetings' }
    let(:base_name) { 'meeting' }
    let(:label_text) { I18n.t('chrono.selector.meeting') }
    let(:free_text_option) { ['true', 'false', nil].sample }
    let(:required_option) { ['true', 'false', nil].sample }
    let(:last_chosen_row) { GogglesDb::Meeting.first(100).sample }

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
          wrapper_class: wrapper_class,
          values: options_from_collection_for_select([last_chosen_row], 'id', 'description', last_chosen_row.id)
        )
      )
    end

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
        .to eq(last_chosen_row.description)
      expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select option").attr('selected')).to be_present
    end
  end
end
