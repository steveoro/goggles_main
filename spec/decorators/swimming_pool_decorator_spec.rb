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
end
