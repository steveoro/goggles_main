# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Icon::CheckMarkComponent, type: :component do
  context 'with a valid parameter,' do
    let(:result_true) { render_inline(described_class.new(value: true)).to_html }
    let(:result_false) { render_inline(described_class.new(value: false)).to_html }
    let(:result_nil) { render_inline(described_class.new(value: nil)).to_html }

    it 'renders two different values for true and false' do
      expect(result_true).not_to eq(result_false)
    end

    it 'renders the same result for both nil and false' do
      expect(result_nil).to eq(result_false)
    end
  end
end
