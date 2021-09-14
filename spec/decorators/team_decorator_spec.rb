# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_decorator_examples'

RSpec.describe TeamDecorator, type: :decorator do
  subject { described_class.decorate(model_obj) }

  let(:model_obj) { GogglesDb::Team.limit(20).sample }

  it_behaves_like('a paginated model decorated with', described_class)

  describe '#link_to_full_name' do
    let(:result) { subject.link_to_full_name }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the editable_name' do
      expect(result).to include(ERB::Util.html_escape(model_obj.editable_name))
    end

    it 'includes the path to the detail page' do
      expect(result).to include(h.team_show_path(id: model_obj.id))
    end
  end
end
