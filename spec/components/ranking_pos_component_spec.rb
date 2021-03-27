# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RankingPosComponent, type: :component do
  [
    -1, 0, 1, 2, 3, 3 + (rand * 100).to_i, nil
  ].each do |ranking_num|
    context "when rank is #{ranking_num}," do
      let(:rendered_result) { render_inline(described_class.new(rank: ranking_num)).to_html }
      it_behaves_like('RankingPosComponent rendering a ranking position', ranking_num)
    end
  end
end
