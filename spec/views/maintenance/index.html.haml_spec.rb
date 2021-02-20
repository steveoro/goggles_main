# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'maintenance/index.html.haml', type: :view do
  before(:each) do
    GogglesDb::AppParameter.maintenance = true
    render
  end

  it 'includes the application title' do
    expect(rendered).to include('Goggles')
  end
  it 'includes the logo' do
    expect(rendered).to include('goggles_blue_128')
  end
  it 'shows the maintenance title' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('maintenance.title')))
  end
  it 'shows the maintenance greeting' do
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('maintenance.see_u_soon')))
  end
end
