# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchDecorator, type: :decorator do
  describe 'self.rendering_parameters' do
    shared_examples_for 'self.rendering_parameters returning non-empty values' do |singular_table_name|
      it 'is an Hash' do
        expect(subject).to be_an(Hash)
      end

      it 'includes the correct :partial name' do
        expect(subject[:partial]).to eq("#{singular_table_name}_results")
      end

      it 'includes the results collection as a :locals variable' do
        expect(subject[:locals][singular_table_name.pluralize.to_sym]).to eq(results_collection)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'with an empty search-results collection' do
      subject { described_class.rendering_parameters(results_collection) }

      let(:results_collection) { GogglesDb::Swimmer.where(id: -1) }

      before { expect(results_collection.empty?).to be true }

      it 'is an Hash' do
        expect(subject).to be_an(Hash)
      end

      it 'includes the empty string :plain' do
        expect(subject[:plain]).to be_a(String).and be_empty
      end
    end

    context 'with a Swimmer search-results collection' do
      subject { described_class.rendering_parameters(results_collection) }

      let(:results_collection) { GogglesDb::Swimmer.for_name('Paul').page(1).per(5) }

      before do
        expect(results_collection.count).to be_positive
        expect(results_collection.first).to be_a(GogglesDb::Swimmer)
      end

      it_behaves_like('self.rendering_parameters returning non-empty values', 'swimmer')
    end

    context 'with a Team search-results collection' do
      subject { described_class.rendering_parameters(results_collection) }

      let(:results_collection) { GogglesDb::Team.for_name('Swimming Club').page(1).per(5) }

      before do
        expect(results_collection.count).to be_positive
        expect(results_collection.first).to be_a(GogglesDb::Team)
      end

      it_behaves_like('self.rendering_parameters returning non-empty values', 'team')
    end

    context 'with a Meeting search-results collection' do
      subject { described_class.rendering_parameters(results_collection) }

      let(:results_collection) { GogglesDb::Meeting.for_name('PROVA').page(1).per(5) }

      before do
        expect(results_collection.count).to be_positive
        expect(results_collection.first).to be_a(GogglesDb::Meeting)
      end

      it_behaves_like('self.rendering_parameters returning non-empty values', 'meeting')
    end

    context 'with a UserWorkshop search-results collection' do
      subject { described_class.rendering_parameters(results_collection) }

      let(:results_collection) { GogglesDb::UserWorkshop.limit(100).page(1).per(5) }

      before do
        expect(results_collection.count).to be_positive
        expect(results_collection.first).to be_a(GogglesDb::UserWorkshop)
      end

      it_behaves_like('self.rendering_parameters returning non-empty values', 'user_workshop')
    end

    context 'with a SwimmingPool search-results collection' do
      subject { described_class.rendering_parameters(results_collection) }

      let(:results_collection) { GogglesDb::SwimmingPool.for_name('Comunale').page(1).per(5) }

      before do
        expect(results_collection.count).to be_positive
        expect(results_collection.first).to be_a(GogglesDb::SwimmingPool)
      end

      it_behaves_like('self.rendering_parameters returning non-empty values', 'swimming_pool')
    end
  end
end
