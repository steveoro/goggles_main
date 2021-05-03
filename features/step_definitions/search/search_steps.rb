# frozen_string_literal: true

When('I search for {string}') do |query_string|
  fill_in('q', with: query_string)
  click_button('btn-search')
end

Then('the {string} search results are displayed, all matching {string}') do |model_downcase_name, query_string|
  results_node = find("##{model_downcase_name.gsub('_', '-')}-results")
  expect(results_node.text).not_to be_empty
  within(results_node) do
    find('table tbody').all('tr').each do |tr_node|
      expect(tr_node.find('td a').text).to match(/#{query_string}/i)
      expect(tr_node.find('td a')[:href]).to match(%r{#{model_downcase_name}s/show/\d+}i)
    end
  end
end

Then('no search results are visible') do
  expect(page).not_to have_css('.swipe-wrapper')
end

Then('the pagination controls are present') do
  content_node = find('.swipe-wrapper', visible: true)
  expect(content_node).to have_css('#paginator-controls')
  paginator_node = find('#paginator-controls')
  expect(paginator_node).to be_present
end

Then('the pagination controls are not present') do
  content_node = find('.swipe-wrapper', visible: true)
  expect(content_node).not_to have_css('#paginator-controls')
end

Then('a flash alert is shown about the empty results') do
  flash_content = find('.flash-body')
  expect(flash_content.text).to eq(I18n.t('search_view.no_results'))
end
