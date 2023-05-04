# frozen_string_literal: true

Then('I can see the chrono index page including the latest request row with details') do
  iq = GogglesDb::ImportQueueDecorator.decorate(GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').last)
  expect(iq.sibling_rows.count).to be_positive
  master_container = find("#main-req#{iq.id}")
  expect(master_container).to be_visible

  # Show detail laps (collapsed by default:
  master_container.find('label.switch-sm').click
  sleep(1) && wait_for_ajax

  # The IQ decorator outputs directly HTML tags with escaped text in it, so here the check is somewhat reversed:
  expect(iq.chrono_result_label).to include(ERB::Util.html_escape(master_container.text))

  collection = iq.sibling_rows.or(GogglesDb::ImportQueue.where(id: iq.id)).includes(:import_queues)
  decorated = GogglesDb::ImportQueueDecorator.decorate_collection(collection)
  decorated.sort_by(&:req_length_in_meters).each do |sibling_row|
    expect(find("li#lap#{sibling_row.id} small")).to be_visible
    # (Same as above: "reversed" check)
    expect(sibling_row.decorate.chrono_delta_label.strip)
      .to include(ERB::Util.html_escape(find("li#lap#{sibling_row.id} small").text))
  end
end

Then('I see the chrono index container with any remaining row for my user') do
  container_node = find('.main-content .container#chrono-rows', visible: true)
  expect(container_node).to be_present
  # Empty domain => no data rows notice
  domain_size = GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').count
  if domain_size.zero?
    expect(container_node.find('.row').text).to include(I18n.t('chrono.index.no_data_notice'))
  else
    expect(container_node.find_all('.row.border').count).to eq(domain_size)
  end
end

# Sets: @deleted_row_id
When('I delete the latest pending chrono request') do
  iq = GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').last
  expect(iq).to be_a(GogglesDb::ImportQueue).and be_valid
  @deleted_row_id = iq.id
  delete_btn = find("#frm-delete-row-#{iq.id}")
  expect(delete_btn).to be_visible
  accept_confirm { delete_btn.click }
end

# Uses: @deleted_row_id
Then('I see that the deleted request is missing from the index') do
  container_node = find('.main-content .container#chrono-rows', visible: true)
  expect(container_node).to be_present
  expect(container_node).not_to have_css(".col#main-req#{@deleted_row_id}")
end

When('I download the chrono request as a JSON file') do
  iq = GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').first
  download_btn = find("#btn-download-json-#{iq.id}")
  expect(download_btn).to be_visible
  download_btn.click
end

When('I can see the chrono request details in the JSON file structure') do
  json_data = JSON.parse(download_content)
  expect(downloaded_filename).to include('chrono-').and include('.json')
  # Check data length:
  iq = GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').first
  expect(json_data.length).to eq(iq.sibling_rows.count + 1)
  # Check contents - master row:
  source_req_json = JSON.parse(iq.request_data)
  expect(json_data[iq.sibling_rows.count]['lap']['order']).to eq(source_req_json['lap']['order'])
  expect(json_data[iq.sibling_rows.count]['lap']['label']).to eq(source_req_json['lap']['label'])
  # Check contents - siblings:
  iq.sibling_rows.each do |sibling_row|
    source_req_json = JSON.parse(sibling_row.request_data)
    # Actual JSON data in downloaded file is sorted by order:
    index_in_sorted_json_data = source_req_json['lap']['order'] - 1
    expect(json_data[index_in_sorted_json_data]['lap']['label']).to eq(source_req_json['lap']['label'])
  end
end

When('I click on the new recording button') do
  find_by_id('btn-new-chrono').click
end
