# frozen_string_literal: true

require 'rails_helper'

# NOTE: specs in this file have access to a helper object that includes
#       the ChronoHelper as in 'helper.<METHOD_NAME>'.
RSpec.describe ChronoHelper, type: :helper do
  describe '#season_options' do
    context 'when rendering with valid data,' do
      let(:fixture_list) { GogglesDb::Season.last(50).sample(3) }
      let(:fixture_ids) { fixture_list.map(&:id) }
      let(:chosen_id) { fixture_ids.sample }
      subject do
        helper.cookies[:season_id] = chosen_id # Simulate a previously made choice
        helper.season_options(fixture_list)
      end
      before(:each) do
        expect(fixture_list).to all be_a(GogglesDb::Season).and be_valid
        expect(fixture_ids.count).to eq(3)
        expect(chosen_id).to be_positive
        expect(subject).to be_present
      end

      it 'renders a list of options' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        expect(nodes.count).to eq(3)
      end
      it 'includes the specified seasons IDs as values' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        nodes.each do |node|
          expect(fixture_ids).to include(node['value'].to_i)
        end
      end
      it 'includes the specified seasons decorated text_labels as option texts' do
        nodes = Nokogiri::HTML.fragment(subject).css('option')
        texts = SeasonDecorator.decorate_collection(fixture_list).map(&:text_label)
        nodes.each do |node|
          expect(texts).to include(node.text)
        end
      end
      it 'pre-selects the previous choice when this is available' do
        node = Nokogiri::HTML.fragment(subject).css("option[selected='selected']")
        expect(node).to be_present
        expect(node.first.attr('value').to_i).to eq(chosen_id)
      end
    end
  end

  describe '#meeting_options' do
    # TODO
  end

  describe '#workshop_options' do
    # TODO
  end

  describe '#pool_type_options' do
    # TODO
  end

  describe '#event_type_options' do
    # TODO
  end

  describe '#category_type_options' do
    # TODO
  end

  describe '#team_options' do
    # TODO
  end
end
