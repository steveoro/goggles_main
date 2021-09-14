# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'lookup/matching_swimmers.html.haml', type: :view do
  context 'when there are matches to show,' do
    let(:matches) { GogglesDb::Swimmer.limit(50).sample(5) }
    # Verify content with Nokogiri:

    let(:rendered_options) { Nokogiri::HTML.fragment(rendered) }

    before do
      expect(matches.count).to eq(5)
      render(partial: 'matching_swimmers', locals: { matches: matches })
    end

    it 'builds an option list valid for an HTML select' do
      expect(rendered_options.css('option').count).to eq(5)
    end

    it 'includes all the matches texts and their id' do
      matches.each_with_index do |swimmer, index|
        decorated_row = SwimmerDecorator.decorate(swimmer)
        expect(rendered_options.css('option')[index].text).to eq(decorated_row.text_label)
        expect(rendered_options.css('option')[index].attr('value')).to eq(decorated_row.id.to_s)
      end
    end
  end

  context 'when there are no matches,' do
    let(:matches) { GogglesDb::Swimmer.none }
    # Verify (absence of) content with Nokogiri:

    let(:rendered_options) { Nokogiri::HTML.fragment(rendered) }

    before do
      expect(matches.count).to eq(0)
      render(partial: 'matching_swimmers', locals: { matches: matches })
    end

    it 'doesn\'t build any option list' do
      expect(rendered_options.css('option').count).to be_zero
    end
  end
end
