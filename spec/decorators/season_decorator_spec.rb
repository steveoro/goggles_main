# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonDecorator, type: :decorator do
  subject(:decorated_instance) { described_class.decorate(fixture_row) }

  let(:fixture_row) { GogglesDb::Season.first(100).sample }

  before do
    expect(fixture_row).to be_a(GogglesDb::Season).and be_valid
    expect(decorated_instance).to be_a(described_class).and be_valid
  end

  describe '#text_label' do
    context 'with a valid row,' do
      subject(:result) { decorated_instance.text_label }

      it 'is a non-empty String' do
        expect(result).to be_a(String).and be_present
      end

      it 'includes the SeasonType short name' do
        expect(result).to include(fixture_row.season_type.short_name)
      end

      it 'includes the header_year' do
        expect(result).to include(fixture_row.header_year)
      end
    end
  end
end
