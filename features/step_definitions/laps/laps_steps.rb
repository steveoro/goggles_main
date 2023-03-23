# frozen_string_literal: true

Then('I can\'t see any of the lap edit buttons on the whole page') do
  table_nodes = find('table.table tbody tr', visible: true)
  expect(table_nodes).not_to have_css('a.btn.lap-edit-btn')
end

Then('I can see the lap edit buttons on the page') do
  expect(page).to have_css('a.btn.lap-edit-btn')
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mir (can be an AbstractResult)
When('I click the button to manage its laps') do
  expect(page).to have_css('a.btn.lap-edit-btn')
  expect(@chosen_mir).to be_a(GogglesDb::AbstractResult).and be_valid
  btn = find("a.btn#lap-req-edit-modal-#{@chosen_mir.id}", visible: true)
  btn.click
  sleep(1) && wait_for_ajax
end

# Uses:
# - @chosen_mir (can be an AbstractResult)
Then('the laps management modal dialog pops up showing its contents') do
  expect(@chosen_mir).to be_a(GogglesDb::AbstractResult).and be_valid
  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)

  expect(dialog.find('h5#lap-edit-modal-title').text).to include(I18n.t('laps.modal.form.title'))
  dialog.find_by_id('lap-edit-modal-body', class: 'modal-body', visible: true)
  dialog.find("a#lap-new25-#{@chosen_mir.id}", visible: true)
  dialog.find("a#lap-new50-#{@chosen_mir.id}", visible: true)
  dialog.find('tbody#laps-table-body', visible: true)
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mir (can be an AbstractResult)
When('I can see the overall result on the last row of the table') do
  result_row = find('tr#laps-result-row', visible: true)
  expect(@chosen_mir).to be_a(GogglesDb::AbstractResult).and be_valid
  expect(result_row.find('input#tot_minutes').value).to eq(@chosen_mir.minutes.to_s)
  expect(result_row.find('input#tot_seconds').value).to eq(@chosen_mir.seconds.to_s)
  expect(result_row.find('input#tot_hundredths').value).to eq(@chosen_mir.hundredths.to_s)
end

# Uses:
# - @chosen_mir (can be an AbstractResult)
When('I choose to add a 25m lap') do
  expect(@chosen_mir).to be_a(GogglesDb::AbstractResult).and be_valid
  before_add = find_all('tbody#laps-table-body tr td .lap-row').count
  find("#lap-edit-modal.modal a#lap-new25-#{@chosen_mir.id}", visible: true).click
  # XJS partial re-rending is pretty slow:
  20.times do
    wait_for_ajax && sleep(1)
    break if find_all('tbody#laps-table-body tr td .lap-row').count > before_add
  end
end

# Sets:
# - @chosen_lap_idx
When('I see another empty lap row is added \(only if the last distance is less than the goal)') do
  last_lap_row = find_all('tbody#laps-table-body tr td .lap-row').last
  @chosen_lap_idx = find_all('tbody#laps-table-body tr td .lap-row').count - 1
  # No empty lap will be created if we've selected a random result that already has laps
  # that fill all the available step distances:
  if @chosen_mir.laps.by_distance.last.length_in_meters + 25 < @chosen_mir.event_type.length_in_meters
    expect(last_lap_row.find("input#minutes_from_start_#{@chosen_lap_idx}").value).to eq('0')
    expect(last_lap_row.find("input#seconds_from_start_#{@chosen_lap_idx}").value).to eq('0')
    expect(last_lap_row.find("input#hundredths_from_start_#{@chosen_lap_idx}").value).to eq('0')
  end
end

# Uses:
# - @chosen_mir (can be an AbstractResult)
# - @chosen_lap_idx
When('I fill the last lap row with some random timing values') do
  expect(@chosen_mir).to be_a(GogglesDb::AbstractResult).and be_valid
  half_timing = Timing.new.from_hundredths((@chosen_mir.to_timing.to_hundredths / 2) - 2)
  fill_in("minutes_from_start_#{@chosen_lap_idx}", with: half_timing.minutes)
  fill_in("seconds_from_start_#{@chosen_lap_idx}", with: half_timing.seconds)
  fill_in("hundredths_from_start_#{@chosen_lap_idx}", with: half_timing.hundredths)
end

# Uses:
# - @chosen_lap_idx
# Sets:
# - @chosen_lap, set as a generic Lap, not serialized, just used as a wrapper to the timings
When('I click to save my edited lap') do
  lap_form_row = find("tbody#laps-table-body tr td form#frm-lap-row-#{@chosen_lap_idx + 1}")
  @chosen_lap = GogglesDb::Lap.new(
    length_in_meters: lap_form_row.find("input#length_in_meters_#{@chosen_lap_idx}").value,
    minutes: lap_form_row.find("input#minutes_from_start_#{@chosen_lap_idx}").value,
    seconds: lap_form_row.find("input#seconds_from_start_#{@chosen_lap_idx}").value,
    hundredths: lap_form_row.find("input#hundredths_from_start_#{@chosen_lap_idx}").value
  )
  find("#lap-save-row-#{@chosen_lap_idx}").click
  wait_for_ajax && sleep(1)
end

# Uses:
# - @chosen_lap_idx
# - @chosen_lap (can be an AbstractLap)
When('I see my chosen lap has been correctly saved') do
  lap_form_row = find("tbody#laps-table-body tr td form#frm-lap-row-#{@chosen_lap_idx + 1}")
  expect(lap_form_row.find("input#length_in_meters_#{@chosen_lap_idx}").value).to eq(@chosen_lap.length_in_meters.to_s)
  expect(lap_form_row.find("input#minutes_from_start_#{@chosen_lap_idx}").value).to eq(@chosen_lap.minutes.to_s)
  expect(lap_form_row.find("input#seconds_from_start_#{@chosen_lap_idx}").value).to eq(@chosen_lap.seconds.to_s)
  expect(lap_form_row.find("input#hundredths_from_start_#{@chosen_lap_idx}").value).to eq(@chosen_lap.hundredths.to_s)
end

When('I dismiss the lap modal editor by clicking on the close button') do
  find_by_id('modal-close', class: 'btn', visible: true).click
  wait_for_ajax && sleep(1)
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_lap_idx
# Updates:
# - @chosen_lap_idx, with the row count before deletion
When('I click to delete my chosen lap and confirm the deletion') do
  before_deletion = find_all('tbody#laps-table-body tr td .lap-row').count
  delete_btn = find("#lap-delete-row-#{@chosen_lap_idx}", visible: true)
  expect(delete_btn).to be_visible
  accept_confirm { delete_btn.click }
  # XJS partial re-rending is pretty slow:
  20.times do
    wait_for_ajax && sleep(1)
    break if find_all('tbody#laps-table-body tr td .lap-row').count < before_deletion
  end
  expect(find_all('tbody#laps-table-body tr td .lap-row').count).to be < before_deletion
  @chosen_lap_idx = before_deletion
end

# ASSUMES: deleted chosen lap was the last added & deleted by the step above
# Uses:
# - @chosen_lap_idx, expected to be an index > row count
When('I can see the chosen lap is no longer shown in the editor') do
  find('tbody#laps-table-body', visible: true)
  wait_for_ajax
  expect(find_all('tbody#laps-table-body tr td .lap-row').count).to be < @chosen_lap_idx
end
# -----------------------------------------------------------------------------
