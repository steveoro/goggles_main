# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_decorator_examples'

RSpec.describe SwimmerDecorator, type: :decorator do
  subject { described_class.decorate(model_obj) }

  let(:model_obj) { GogglesDb::Swimmer.limit(50).sample }
  let(:swimmer_with_badge) { new_badge.swimmer }
  let(:new_swimmer) { FactoryBot.create(:swimmer) }
  #-- -------------------------------------------------------------------------
  #++

  let(:new_badge)   { FactoryBot.create(:badge) }
  #-- -------------------------------------------------------------------------
  #++

  let(:new_badge)   { FactoryBot.create(:badge) }
  let(:new_swimmer) { FactoryBot.create(:swimmer) }
  let(:swimmer_with_badge) { new_badge.swimmer }

  before do
    expect(model_obj).to be_a(GogglesDb::Swimmer).and be_valid
    expect(subject).to be_a(described_class).and be_valid
  end

  before do
    expect(new_badge).to be_a(GogglesDb::Badge).and be_valid
    expect(new_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    expect(GogglesDb::Badge.for_swimmer(new_swimmer)).to be_empty
    expect(swimmer_with_badge).to be_a(GogglesDb::Swimmer).and be_valid
  end

  it_behaves_like('a paginated model decorated with', described_class)

  describe '#text_label' do
    let(:result) { subject.text_label }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the complete name' do
      expect(result).to include(ERB::Util.html_escape(model_obj.complete_name))
    end

    it 'includes the year_of_birth' do
      expect(result).to include(model_obj.year_of_birth.to_s)
    end
  end

  describe '#link_to_full_name' do
    let(:result) { subject.link_to_full_name }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the complete name' do
      expect(result).to include(ERB::Util.html_escape(model_obj.complete_name))
    end

    it 'includes the path to the swimmer dashboard' do
      expect(result).to include(h.swimmer_show_path(id: model_obj.id))
    end
  end

  # describe '#associated_team_ids' do
  #   context 'with a swimmer with existing badges,' do
  #     let(:result) { described_class.decorate(swimmer_with_badge).associated_team_ids }

  #     it 'is a non-empty Array' do
  #       expect(result).to be_an(Array)
  #       expect(result.count).to be_positive
  #     end

  #     it 'contains only valid associations with Teams' do
  #       expect(GogglesDb::Team.where(id: result)).to all be_a(GogglesDb::Team)
  #     end
  #   end

  #   context 'with a swimmer without any badge,' do
  #     let(:result) { described_class.decorate(new_swimmer).associated_team_ids }

  #     it 'is an empty Array' do
  #       expect(result).to be_an(Array).and be_empty
  #     end
  #   end
  # end
  #-- -------------------------------------------------------------------------
  #++

  describe '#link_to_teams' do
    before do
      expect(new_badge).to be_a(GogglesDb::Badge).and be_valid
      expect(new_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
      expect(GogglesDb::Badge.for_swimmer(new_swimmer)).to be_empty
      expect(swimmer_with_badge).to be_a(GogglesDb::Swimmer).and be_valid
    end

    context 'with a swimmer with existing badges,' do
      let(:decorated_obj) { described_class.decorate(swimmer_with_badge) }
      let(:team_ids) { decorated_obj.associated_team_ids }
      let(:result)   { decorated_obj.link_to_teams }

      it 'is a non-empty String' do
        expect(result).to be_a(String).and be_present
      end

      it 'includes all links to the associated Team details page' do
        team_ids.each do |team_id|
          expect(result).to include(h.team_show_path(id: team_id))
        end
      end

      it 'includes all associated team names (truncated with a default of 20 chars)' do
        team_names = GogglesDb::Team.where(id: team_ids)
                                    .map { |team| h.truncate(team.editable_name, length: 20, separator: ' ') }
        team_names.each do |shortened_team_name|
          expect(result).to include(ERB::Util.html_escape(shortened_team_name))
        end
      end
    end

    context 'with a swimmer without any badge,' do
      let(:result) { described_class.decorate(new_swimmer).link_to_teams }

      it 'does not include any list item in the resulting HTML list' do
        expect(result).not_to include('<li>')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
