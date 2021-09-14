# frozen_string_literal: true

require 'rails_helper'

# NOTE: specs in this file have access to a helper object that includes
#       the ChronoHelper as in 'helper.<METHOD_NAME>'.
RSpec.describe ChronoHelper, type: :helper do
  # ASSERT / needs:
  # - subject => already existing & rendered
  shared_examples_for 'chrono helper with an empty or nil parameter' do
    it 'does not throw an error' do
      expect { subject }.not_to raise_error
    end

    it 'renders nil' do
      expect(subject).to be nil
    end
  end

  # ASSERT / needs:
  # - fixture_list => list of fixture rows, domain for the options
  # - fixture_ids  => map of IDs from all the domain rows
  # - chosen_id    => previously chosen ID (among the domain rows)
  # - subject      => already existing & rendered
  shared_examples_for 'chrono helper with valid data & paramenters (common behavior)' do
    it 'renders a list of options' do
      nodes = Nokogiri::HTML.fragment(subject).css('option')
      expect(nodes.count).to eq(fixture_list.count)
    end

    it 'includes the specified fixture IDs as values' do
      nodes = Nokogiri::HTML.fragment(subject).css('option')
      nodes.each do |node|
        expect(fixture_ids).to include(node['value'].to_i)
      end
    end

    it 'pre-selects the previous choice when this is available' do
      node = Nokogiri::HTML.fragment(subject).css("option[selected='selected']")
      expect(node).to be_present
      expect(node.first.attr('value').to_i).to eq(chosen_id)
    end
  end

  # ASSERT / needs:
  # - fixture_list => list of fixture rows, domain for the options
  # - fixture_ids  => map of IDs from all the domain rows
  # - chosen_id    => previously chosen ID (among the domain rows)
  # - subject      => already existing & rendered
  shared_examples_for 'chrono helper with valid data & paramenters' do |label_symbol|
    it_behaves_like('chrono helper with valid data & paramenters (common behavior)')

    it 'includes the specified fixture short_names as option texts' do
      nodes = Nokogiri::HTML.fragment(subject).css('option')
      texts = fixture_list.map(&label_symbol)
      nodes.each do |node|
        expect(texts).to include(node.text)
      end
    end
  end

  # ASSERT / needs:
  # - fixture_row => single fixture row (pre-existing choice)
  # - subject      => already existing & rendered
  shared_examples_for 'chrono helper based on a single pre-existing choice' do
    it 'renders a list with a single option' do
      nodes = Nokogiri::HTML.fragment(subject).css('option')
      expect(nodes.count).to eq(1)
    end

    it 'includes the previous choice ID as value' do
      nodes = Nokogiri::HTML.fragment(subject).css('option')
      expect(nodes.first['value'].to_i).to eq(fixture_row.id)
    end

    it 'includes the previous choice description as option texts' do
      nodes = Nokogiri::HTML.fragment(subject).css('option')
      expect(nodes.first.text).to eq(fixture_row.description)
    end

    it 'pre-selects the previous choice' do
      node = Nokogiri::HTML.fragment(subject).css("option[selected='selected']")
      expect(node).to be_present
      expect(node.first.attr('value').to_i).to eq(fixture_row.id)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#season_options' do
    context 'when rendering with valid data,' do
      subject do
        helper.cookies[:season_id] = chosen_id # Simulate a previously made choice
        helper.season_options(fixture_list)
      end

      let(:fixture_list) { GogglesDb::Season.last(50).sample(3) }
      let(:fixture_ids) { fixture_list.map(&:id) }
      let(:chosen_id) { fixture_ids.sample }

      before do
        expect(fixture_list).to all be_a(GogglesDb::Season).and be_valid
        expect(fixture_ids.count).to eq(fixture_list.count)
        expect(chosen_id).to be_positive
        expect(subject).to be_present
      end

      it_behaves_like('chrono helper with valid data & paramenters (common behavior)')

      it 'includes the specified fixture decorated text_labels as option texts' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        texts = SeasonDecorator.decorate_collection(fixture_list).map(&:text_label)
        nodes.each do |node|
          expect(texts).to include(node.text)
        end
      end
    end

    context 'when rendering with a nil parameter,' do
      subject { helper.season_options(nil) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end

    context 'when rendering with an empty list,' do
      subject { helper.season_options([]) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#meeting_options' do
    context 'when rendering with a previous choice existing,' do
      subject do
        # Simulate a previously made choice:
        helper.cookies[:meeting_id] = fixture_row.id
        helper.cookies[:meeting_label] = fixture_row.description
        helper.meeting_options
      end

      let(:fixture_row) { GogglesDb::Meeting.last(50).sample }

      before do
        expect(fixture_row).to be_a(GogglesDb::Meeting).and be_valid
        expect(subject).to be_present
        expect(helper.cookies[:meeting_id]).to be_present
        expect(helper.cookies[:meeting_label]).to be_present
      end

      it_behaves_like('chrono helper based on a single pre-existing choice')
    end

    context 'when rendering without any previous choice being made,' do
      subject { helper.meeting_options }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#workshop_options' do
    context 'when rendering with a previous choice existing,' do
      subject do
        # Simulate a previously made choice:
        helper.cookies[:user_workshop_id] = fixture_row.id
        helper.cookies[:user_workshop_label] = fixture_row.description
        helper.workshop_options
      end

      let(:fixture_row) { FactoryBot.create(:user_workshop) }

      before do
        expect(fixture_row).to be_a(GogglesDb::UserWorkshop).and be_valid
        expect(subject).to be_present
        expect(helper.cookies[:user_workshop_id]).to be_present
        expect(helper.cookies[:user_workshop_label]).to be_present
      end

      it_behaves_like('chrono helper based on a single pre-existing choice')
    end

    context 'when rendering without any previous choice being made,' do
      subject { helper.workshop_options }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#pool_type_options' do
    context 'when rendering with valid data,' do
      subject do
        helper.cookies[:pool_type_id] = chosen_id # Simulate a previously made choice
        helper.pool_type_options(fixture_list)
      end

      let(:fixture_list) { GogglesDb::PoolType.all.to_a }
      let(:fixture_ids) { fixture_list.map(&:id) }
      let(:chosen_id) { fixture_ids.sample }

      before do
        expect(fixture_list).to all be_a(GogglesDb::PoolType).and be_valid
        expect(fixture_ids.count).to eq(fixture_list.count)
        expect(chosen_id).to be_positive
        expect(subject).to be_present
      end

      it_behaves_like('chrono helper with valid data & paramenters', :long_label)
    end

    context 'when rendering with a nil parameter,' do
      subject { helper.pool_type_options(nil) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end

    context 'when rendering with an empty list,' do
      subject { helper.pool_type_options([]) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#event_type_options' do
    context 'when rendering with valid data,' do
      subject do
        helper.cookies[:event_type_id] = chosen_id # Simulate a previously made choice
        helper.event_type_options(fixture_list)
      end

      let(:fixture_list) { GogglesDb::EventType.all_individuals }
      let(:fixture_ids) { fixture_list.map(&:id) }
      let(:chosen_id) { fixture_ids.sample }

      before do
        expect(fixture_list).to all be_a(GogglesDb::EventType).and be_valid
        expect(fixture_ids.count).to eq(fixture_list.count)
        expect(chosen_id).to be_positive
        expect(subject).to be_present
      end

      it_behaves_like('chrono helper with valid data & paramenters', :long_label)
    end

    context 'when rendering with a nil parameter,' do
      subject { helper.event_type_options(nil) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end

    context 'when rendering with an empty list,' do
      subject { helper.event_type_options([]) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#category_type_options' do
    context 'when rendering with valid data,' do
      subject do
        helper.cookies[:category_type_id] = chosen_id # Simulate a previously made choice
        helper.category_type_options(fixture_list)
      end

      let(:fixture_list) { GogglesDb::CategoryType.first(50).sample(5) }
      let(:fixture_ids) { fixture_list.map(&:id) }
      let(:chosen_id) { fixture_ids.sample }

      before do
        expect(fixture_list).to all be_a(GogglesDb::CategoryType).and be_valid
        expect(fixture_ids.count).to eq(fixture_list.count)
        expect(chosen_id).to be_positive
        expect(subject).to be_present
        expect(helper.cookies[:category_type_id]).to be_present
      end

      it_behaves_like('chrono helper with valid data & paramenters', :short_name)
    end

    context 'when rendering with a nil parameter,' do
      subject { helper.category_type_options(nil) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end

    context 'when rendering with an empty list,' do
      subject { helper.category_type_options([]) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#team_options' do
    let(:last_chosen_team) { GogglesDb::Team.first(50).sample }
    let(:last_chosen_swimmer) { GogglesDb::Swimmer.first(150).sample }

    shared_examples_for 'chrono helper, team_options valid domain behaviour' do
      it 'renders a list with a single option' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        expect(nodes.count).to eq(1)
      end

      it 'includes the previous *Team* ID as value (Team has precendence)' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        expect(nodes.first['value'].to_i).to eq(last_chosen_team.id)
      end

      it 'includes the previous *Team name as option text (Team has precendence)' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        expect(nodes.first.text).to eq(last_chosen_team.name)
      end

      it 'pre-selects the previous choice (Team has precendence)' do
        node = Nokogiri::HTML.fragment(subject).css("option[selected='selected']")
        expect(node).to be_present
        expect(node.first.attr('value').to_i).to eq(last_chosen_team.id)
      end
    end

    context 'when both last_chosen_team & last_chosen_swimmer are valid,' do
      subject { helper.team_options(last_chosen_team, last_chosen_swimmer) }

      before do
        expect(last_chosen_team).to be_a(GogglesDb::Team).and be_valid
        expect(last_chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        expect(subject).to be_present
      end

      it_behaves_like('chrono helper, team_options valid domain behaviour')
    end

    context 'when both last_chosen_team & last_chosen_swimmer are nil,' do
      subject { helper.team_options(nil, nil) }

      it_behaves_like('chrono helper with an empty or nil parameter')
    end

    context 'when last_chosen_team is valid but last_chosen_swimmer is nil,' do
      subject { helper.team_options(last_chosen_team, nil) }

      before do
        expect(last_chosen_team).to be_a(GogglesDb::Team).and be_valid
        expect(subject).to be_present
      end

      it_behaves_like('chrono helper, team_options valid domain behaviour')
    end

    context 'when last_chosen_team is nil but last_chosen_swimmer is valid,' do
      subject { helper.team_options(nil, last_chosen_swimmer) }

      let(:available_teams) { SwimmerDecorator.decorate(last_chosen_swimmer).associated_teams }

      before do
        expect(last_chosen_swimmer).to be_a(GogglesDb::Swimmer).and be_valid
        expect(subject).to be_present
        expect(available_teams).to respond_to(:count).and respond_to(:each)
      end

      it 'renders an option list (with the same number of teams of the last chosen Swimmer)' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        expect(nodes.count).to eq(available_teams.count)
      end

      it 'includes the previous Swimmer teams IDs as value (if there are any)' do
        return true unless available_teams.count.positive?

        nodes = Nokogiri::HTML.fragment(subject).css('option')
        domain_ids = available_teams.map(&:id)
        nodes.each do |node|
          expect(domain_ids).to include(node['value'].to_i)
        end
      end

      it 'includes the previous Swimmer teams names as option text (if there are any)' do
        return true unless available_teams.count.positive?

        nodes = Nokogiri::HTML.fragment(subject).css('option')
        domain_labels = available_teams.map(&:editable_name)
        nodes.each do |node|
          expect(domain_labels).to include(node.text)
        end
      end

      it 'pre-selects the previous choice (Swimmer first associated Team, if there are any)' do
        return true unless available_teams.count.positive?

        node = Nokogiri::HTML.fragment(subject).css("option[selected='selected']")
        expect(node).to be_present
        expect(node.first.attr('value').to_i).to eq(available_teams.first.id)
      end
    end
  end
end
