# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grid::FilterShowButtonComponent, type: :component do
  subject { render_inline(described_class.new) }

  it 'renders the button with the collapse toggle parameter for the filters section' do
    expect(subject.css('button.btn')).to be_present
    expect(subject.css('button.btn').attr('data-target').value).to eq('#filter-panel')
    expect(subject.css('button.btn').attr('data-toggle').value).to eq('collapse')
  end
end
