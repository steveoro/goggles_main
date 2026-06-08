# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/index.html.haml' do
  before do
    assign(:app_settings_row, GogglesDb::AppParameter.versioning_row)
    render
  end

  context 'before searching anything,' do
    it 'shows the query search box' do
      expect(rendered).to match(/id=['"]search-box['"]/)
      expect(rendered).to match(/data-controller=['"]loading['"]/)
      expect(rendered).to include('turbo:submit-start-&gt;loading#show')
      expect(rendered).to match(/id=['"]q['"]/)
      expect(rendered).to match(/id=['"]btn-search['"]/)
    end

    it 'has an empty query as default' do
      # Verify node content with Nokogiri:
      node = Nokogiri::HTML.fragment(rendered).at_css('#q')
      expect(node.text).to be_empty
      expect(node.inner_html).to be_empty
    end

    it 'includes the empty search result turbo frame' do
      node = Nokogiri::HTML.fragment(rendered).at_css('turbo-frame#search-results')
      expect(node).to be_present
      expect(node.inner_html.strip).to be_empty
    end
  end
end
