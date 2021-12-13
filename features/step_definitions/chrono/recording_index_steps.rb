# frozen_string_literal: true

Then('I can see the chrono index page with an expandable row with details') do
  iq = GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').first
  expect(iq.sibling_rows.count).to be_positive
  master_container = find("#main-req#{iq.id}")
  expect(master_container).to be_visible
  expect(master_container.text).to include(GogglesDb::ImportQueueDecorator.decorate(iq).text_label.strip)
  # Show detail laps (collapsed by default:
  master_container.find('label.switch-sm').click
  sleep(1) && wait_for_ajax
  iq.sibling_rows.each do |sibling_row|
    expect(find("li#lap#{sibling_row.id} small")).to be_visible
    expect(find("li#lap#{sibling_row.id} small").text).to include(sibling_row.decorate.text_label.strip)
  end
end

Then('I can see the empty chrono index page') do
  expect(find('.main-content .container .row.list-group-item').text).to include(I18n.t('chrono.index.no_data_notice'))
  # Make sure the "no data" notice is also due to an empty domain:
  expect(GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').count).to be_zero
end

When('I delete the pending chrono request') do
  iq = GogglesDb::ImportQueue.for_user(@current_user).for_uid('chrono').first
  delete_btn = find("#frm-delete-row-#{iq.id}")
  expect(delete_btn).to be_visible
  accept_confirm { delete_btn.click }
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
  expect(json_data[3]['lap']['order']).to eq(source_req_json['lap']['order'])
  expect(json_data[3]['lap']['label']).to eq(source_req_json['lap']['label'])
  # Check contents - siblings:
  iq.sibling_rows.each do |sibling_row|
    source_req_json = JSON.parse(sibling_row.request_data)
    # Actual JSON data in downloaded file is sorted by order:
    index_in_sorted_json_data = source_req_json['lap']['order'] - 1
    expect(json_data[index_in_sorted_json_data]['lap']['label']).to eq(source_req_json['lap']['label'])
  end
end

When('I click on the new recording button') do
  find('#btn-new-chrono').click
end
