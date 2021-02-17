# frozen_string_literal: true

When('I browse to the root page') do
  visit(root_path)
end

When('I search for {string}') do |query_string|
  fill_in('q', with: query_string)
  click_button('btn-search')
end

Then('the {string} search results are displayed, all matching {string}') do |model_downcase_name, _query_string|
  node = find("##{model_downcase_name}-results", visible: true)
  expect(node.text).not_to be_empty

  # TODO
end

Then('the pagination controls are visible') do
  content_node = find('.swipe-wrapper', visible: true)
  expect(content_node).to have_css('#paginator-controls')
  paginator_node = find('#paginator-controls')
  expect(paginator_node).to be_visible
end

Then('the pagination controls are not present') do
  content_node = find('.swipe-wrapper', visible: true)
  expect(content_node).not_to have_css('#paginator-controls')
end
