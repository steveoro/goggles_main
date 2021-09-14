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

  describe '#swimmer_age' do
    context 'with no parameters,' do
      it 'returns the current age of the swimmer' do
        expect(subject.swimmer_age).to eq(Time.zone.today.year - model_obj.year_of_birth)
      end
    end

    context 'for a given date,' do
      it 'returns the age of the swimmer during that date\'s year' do
        sample_date = Time.zone.today + (rand * 30 - rand * 15).to_i.years
        expect(subject.swimmer_age(sample_date)).to eq(sample_date.year - model_obj.year_of_birth)
      end
    end
  end

  describe '#text_label' do
    let(:result) { subject.text_label }

    it 'is a non-empty String' do
      expect(result).to be_a(String).and be_present
    end

    it 'includes the complete name' do
      expect(result).to include(ERB::Util.html_escape(model_obj.complete_name))
    end

    it 'includes the year_of_birth in between parenthesys' do
      expect(result).to include("(#{model_obj.year_of_birth})")
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

  describe '#associated_team_ids' do
    context 'for a swimmer with existing badges,' do
      let(:result) { described_class.decorate(swimmer_with_badge).associated_team_ids }

      it 'is a non-empty Array' do
        expect(result).to be_an(Array)
        expect(result.count).to be_positive
      end

      it 'contains only valid associations with Teams' do
        expect(GogglesDb::Team.where(id: result)).to all be_a(GogglesDb::Team)
      end
    end

    context 'for a swimmer without any badge,' do
      let(:result) { described_class.decorate(new_swimmer).associated_team_ids }

      it 'is an empty Array' do
        expect(result).to be_an(Array).and be_empty
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#link_to_teams' do
    before do
      expect(new_badge).to be_a(GogglesDb::Badge).and be_valid
      expect(new_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
      expect(GogglesDb::Badge.for_swimmer(new_swimmer)).to be_empty
      expect(swimmer_with_badge).to be_a(GogglesDb::Swimmer).and be_valid
    end

    context 'for a swimmer with existing badges,' do
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

    context 'for a swimmer without any badge,' do
      let(:result) { described_class.decorate(new_swimmer).link_to_teams }

      it 'does not include any list item in the resulting HTML list' do
        expect(result).not_to include('<li>')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#last_category_code' do
    context 'for a swimmer with existing badges,' do
      let(:result_code) { described_class.decorate(swimmer_with_badge).last_category_code }

      it 'returns a non-empty string category code' do
        expect(result_code).to be_a(String).and be_present
      end

      it 'is the category code for the latest associated badge' do
        latest_badge = GogglesDb::Badge.for_swimmer(swimmer_with_badge)
                                       .by_season
                                       .includes(:category_type)
                                       .last
        expect(result_code).to eq(latest_badge.category_type.code)
      end
    end

    context 'for a swimmer without any badge,' do
      let(:result_code) { described_class.decorate(new_swimmer).last_category_code }

      it 'returns nil' do
        expect(result_code).to be_nil
      end
    end
  end

  describe '#current_fin_category_code' do
    context 'for a swimmer with at least an existing badge (not necessarily registered to the FIN Championship),' do
      let(:decorated_obj) { described_class.decorate(swimmer_with_badge) }
      let(:result_code) { decorated_obj.current_fin_category_code }
      let(:category_type) { GogglesDb::CategoryType.find_by(code: result_code) }

      it 'returns a valid CategoryType code' do
        expect(category_type).to be_a(GogglesDb::CategoryType).and be_valid
      end

      it 'returns a category (code) which range covers the swimmer age' do
        expect(category_type.age_begin..category_type.age_end).to cover(decorated_obj.swimmer_age)
      end
    end

    context 'for a swimmer without any badge,' do
      let(:decorated_obj) { described_class.decorate(new_swimmer) }
      let(:result_code) { decorated_obj.current_fin_category_code }
      let(:category_type) { GogglesDb::CategoryType.find_by(code: result_code) }

      it 'returns a valid CategoryType code' do
        expect(category_type).to be_a(GogglesDb::CategoryType).and be_valid
      end

      it 'returns a category (code) which range covers the swimmer age' do
        expect(category_type.age_begin..category_type.age_end).to cover(decorated_obj.swimmer_age)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
