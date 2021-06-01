# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_decorator_examples'

RSpec.describe SwimmingPoolDecorator, type: :decorator do
  let(:model_obj) { GogglesDb::SwimmingPool.limit(20).sample }
  subject { SwimmingPoolDecorator.decorate(model_obj) }

  it_behaves_like('a paginated model decorated with', SwimmingPoolDecorator)

  describe '#link_to_full_name' do
    let(:result) { subject.link_to_full_name }
    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end
    it 'includes the name' do
      expect(result).to include(ERB::Util.html_escape(model_obj.name))
    end
    it 'includes the path to the detail page' do
      expect(result).to include(h.swimming_pool_show_path(id: model_obj.id))
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Requires:
  # - model_obj: the domain model object
  # - result: result to be tested
  shared_examples_for '#link_to_maps_or_name rendering successfully the link' do
    it 'returns a non-empty string' do
      expect(result).to be_a(String).and be_present
    end
    it 'does not include empty parameters in the link URL' do
      expect(result).not_to include('++')
    end
    it 'includes the link' do
      expect(result).to include('href=')
    end
    it 'includes the correct protocol' do
      expect(result).to include('https://')
    end
    it 'includes the swimming pool name' do
      expect(result).to include(
        ERB::Util.html_escape(model_obj.name)
      ).or include(model_obj.name)
    end
  end

  describe '#link_to_maps_or_name' do
    context 'for a pool that includes plus_code' do
      let(:model_obj) { GogglesDb::SwimmingPool.where('plus_code != ""').limit(20).sample }
      subject { SwimmingPoolDecorator.decorate(model_obj) }
      let(:result) { subject.link_to_maps_or_name }

      it_behaves_like('#link_to_maps_or_name rendering successfully the link')
    end

    context 'for a pool that includes maps_uri but not plus_code' do
      let(:model_obj) { GogglesDb::SwimmingPool.where('maps_uri != ""').limit(20).sample }
      subject do
        expect(model_obj.maps_uri).to be_present
        model_obj.plus_code = nil
        SwimmingPoolDecorator.decorate(model_obj)
      end
      let(:result) { subject.link_to_maps_or_name }

      it_behaves_like('#link_to_maps_or_name rendering successfully the link')
    end

    context 'for a pool that includes latitude & longitude but not plus_code or maps_uri' do
      let(:model_obj) { FactoryBot.build(:swimming_pool, latitude: 44.123, longitude: 17.123) }
      subject do
        expect(model_obj.plus_code).to be nil
        expect(model_obj.maps_uri).to be nil
        SwimmingPoolDecorator.decorate(model_obj)
      end
      let(:result) { subject.link_to_maps_or_name }

      it_behaves_like('#link_to_maps_or_name rendering successfully the link')
    end

    context 'for a pool that includes just its city (no address)' do
      let(:model_obj) { FactoryBot.build(:swimming_pool, address: nil) }
      subject do
        expect(model_obj.latitude).to be nil
        expect(model_obj.longitude).to be nil
        expect(model_obj.plus_code).to be nil
        expect(model_obj.maps_uri).to be nil
        SwimmingPoolDecorator.decorate(model_obj)
      end
      let(:result) { subject.link_to_maps_or_name }

      it_behaves_like('#link_to_maps_or_name rendering successfully the link')
    end

    # Both city_id & address missing and no coordinates at all:
    context 'for a pool for which is known just by the name' do
      let(:model_obj) { FactoryBot.build(:swimming_pool, city_id: nil, address: nil) }
      subject do
        expect(model_obj.latitude).to be nil
        expect(model_obj.longitude).to be nil
        expect(model_obj.plus_code).to be nil
        expect(model_obj.maps_uri).to be nil
        SwimmingPoolDecorator.decorate(model_obj)
      end
      let(:result) { subject.link_to_maps_or_name }

      it 'returns just the name string' do
        expect(result).to eq(model_obj.name)
      end
    end
  end
end
