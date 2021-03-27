# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mevent::RowSeparatorComponent, type: :component do
  subject { render_inline(described_class.new).to_html }

  it 'renders an empty table row spanning 4 columns' do
    node = Nokogiri::HTML.fragment(subject).at_css('tr th')
    expect(node).to be_present
    expect(node.text).not_to be_present
    expect(node[:colspan]).to eq('4')
  end
end
