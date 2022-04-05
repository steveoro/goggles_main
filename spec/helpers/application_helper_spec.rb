# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#grid_filter_to_labels' do
    let(:main_namespace) { 'user_workshops.dashboard' }
    let(:grid_filter_params) do
      {
        'rejectable_nil' => nil,
        'rejectable_empty' => '',
        'order' => 'WHATEVER',
        'descending' => 'true',
        'workshop_date' => '2018-01-01',
        'workshop_name' => 'Any Fake Workshop'
      }
    end

    context 'when rendering with valid parameters,' do
      subject { helper.grid_filter_to_labels(main_namespace, grid_filter_params) }

      before do
        expect(main_namespace).to be_present
        expect(grid_filter_params).to be_an(Hash)
      end

      it 'returns a non-empty string' do
        expect(subject).to be_a(String).and be_present
      end

      it 'does not include the ordering and direction inside the verbose filters' do
        expect(subject).not_to include('WHATEVER')
        expect(subject).not_to include('true')
      end

      it 'returns just the localization of the specified filters' do
        expect(subject).to eq(
          [
            I18n.t("#{main_namespace}.params.workshop_date", value: grid_filter_params['workshop_date']),
            I18n.t("#{main_namespace}.params.workshop_name", value: grid_filter_params['workshop_name'])
          ].join(', ')
        )
      end
    end

    context 'when rendering with a nil parameter,' do
      subject { helper.grid_filter_to_labels(main_namespace, nil) }

      it 'is an empty string' do
        expect(subject).to eq('')
      end
    end

    context 'when rendering without any filtering parameters,' do
      subject { helper.grid_filter_to_labels(main_namespace, { 'order' => 'ANY_COLUMN' }) }

      it 'is an empty string' do
        expect(subject).to eq('')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
