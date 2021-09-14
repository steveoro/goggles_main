# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/index.html.haml', type: :view do
  before do
    assign(:app_settings_row, GogglesDb::AppParameter.versioning_row)
    render
  end

  context 'before searching anything,' do
    it 'shows the query search box' do
      expect(rendered).to match(/id=['"]search-box['"]/)
      expect(rendered).to include('#loading-indicator')
      expect(rendered).to match(/id=['"]q['"]/)
      expect(rendered).to match(/id=['"]btn-search['"]/)
    end

    it 'has an empty query as default' do
      # Verify node content with Nokogiri:
      node = Nokogiri::HTML.fragment(rendered).at_css('#q')
      expect(node.text).to be_empty
      expect(node.inner_html).to be_empty
    end

    it 'includes the empty search result div' do
      expect(rendered).to match(%r{\sid=['"]search-results['"]></div>})
    end
  end
end
