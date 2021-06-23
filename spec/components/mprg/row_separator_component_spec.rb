# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mprg::RowSeparatorComponent, type: :component do
  subject { render_inline(described_class.new) }

  it 'renders an empty table row spanning 4 columns' do
    expect(subject.at_css('tr th')).to be_present
    expect(subject.at_css('tr th').text).not_to be_present
    expect(subject.at_css('tr th')[:colspan]).to eq('4')
  end
end
