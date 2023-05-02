# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_decorator_examples'

RSpec.describe TeamDecorator, type: :decorator do
  subject { described_class.decorate(model_obj) }

  let(:model_obj) { GogglesDb::Team.limit(20).sample }

  it_behaves_like('a paginated model decorated with', described_class)

  describe '#text_label' do
    let(:result) { subject.text_label }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the team #editable_name' do
      expect(result).to include(model_obj.editable_name)
    end
  end

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

  describe '#link_to_results(meeting_id)' do
    let(:meeting_id) { [GogglesDb::Meeting, GogglesDb::UserWorkshop].sample.last(150).sample.id }
    let(:result) { subject.link_to_results(meeting_id) }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the #text_label' do
      expect(result).to include(ERB::Util.html_escape(subject.text_label))
    end

    it 'includes the path to the team results page' do
      expect(result).to include(h.meeting_team_results_path(id: meeting_id, team_id: model_obj.id))
    end
  end

  it_behaves_like('#decorated for a core model with a core decorator', GogglesDb::TeamDecorator)
end
