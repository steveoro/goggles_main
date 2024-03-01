# frozen_string_literal: true

# Uses:
# - @chosen_mrr
When('I click the button to manage its relay laps') do
  sleep(1) && wait_for_ajax
  expect(page).to have_css('a.btn.lap-edit-btn')
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  step("I trigger the click event on the 'a.btn#lap-req-edit-modal-#{@chosen_mrr.id}' DOM ID")
end

# Uses:
# - @chosen_mrr
Then('the relay laps management modal dialog pops up showing its contents') do
  expect(@chosen_mrr.id).to be_positive
  # Avoid Bullet complaining about missing eager loading:
  @chosen_mrr = GogglesDb::MeetingRelayResult.includes(meeting_relay_swimmers: :relay_laps).find(@chosen_mrr.id)
  expect(@chosen_mrr).to be_valid
  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)

  expect(dialog.find('h5#lap-edit-modal-title').text).to include(I18n.t('laps.modal.form.title'))
  dialog.find_by_id('lap-edit-modal-body', class: 'modal-body', visible: true)
  dialog.find('tbody#laps-table-body', visible: true)
  dialog.find('form#frm-add-mrs-row', visible: true)
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrr
When('there is a MRS edit form row with support for RelayLaps for each row belonging to the MRR') do
  expect(@chosen_mrr.id).to be_positive
  # Avoid Bullet complaining about missing eager loading:
  @chosen_mrr = GogglesDb::MeetingRelayResult.includes(meeting_relay_swimmers: :relay_laps).find(@chosen_mrr.id)
  expect(@chosen_mrr).to be_valid
  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)

  laps_table = dialog.find('tbody#laps-table-body', visible: true)
  event_type = @chosen_mrr.event_type
  max_relay_laps = (event_type.phase_length_in_meters / 50) - 1

  # MRS-laps: (when present)
  @chosen_mrr.meeting_relay_swimmers.by_order.each_with_index do |mrs, mrs_index|
    overall_index = (mrs_index + 1) * (max_relay_laps + 1)
    mrs_hdr = laps_table.find("tr#mrs-header-row-#{overall_index} td", visible: true)
    # Title presence:
    expect(mrs_hdr.find('h6', visible: true).text).to include(mrs.swimmer.complete_name)
    # Row widgets:
    can_have_sublaps = mrs.id.to_i.positive? && event_type.phase_length_in_meters > 50 && mrs.relay_laps.to_a.length < max_relay_laps
    laps_table.find("a#lap-new50-#{mrs.id}", visible: true) if can_have_sublaps
    laps_table.find("a#lap-delete-row-#{overall_index}", visible: true) if mrs.id.to_i.positive?
    # Row edit:
    expect(laps_table.find("input#length_in_meters_#{overall_index}").value).to eq(mrs.length_in_meters.to_s)
    expect(laps_table.find("input#minutes_from_start_#{overall_index}").value).to eq(mrs.minutes_from_start.to_s)
    expect(laps_table.find("input#seconds_from_start_#{overall_index}").value).to eq(mrs.seconds_from_start.to_s)
    expect(laps_table.find("input#hundredths_from_start_#{overall_index}").value).to eq(mrs.hundredths_from_start.to_s)
    expect(laps_table.find("#lap-save-row-#{overall_index}")).to be_present
    expect(laps_table.find("span#mrs-delta-#{overall_index}").text).to include("Δt: #{mrs.to_timing}")
    # Sub-laps: (when present)
    mrs.relay_laps.each_with_index do |relay_lap, sub_index|
      sublap_index = (mrs_index * event_type.phase_length_in_meters / 50) + sub_index + 1
      rl_form = laps_table.find("form#frm-sublap-row-#{sublap_index}")
      expect(rl_form).to be_present
      expect(rl_form.find("input#length_in_meters_#{sublap_index}").value).to eq(relay_lap.length_in_meters.to_s)
      expect(rl_form.find("input#minutes_from_start_#{sublap_index}").value).to eq(relay_lap.minutes_from_start.to_s)
      expect(rl_form.find("input#hundredths_from_start_#{sublap_index}").value).to eq(relay_lap.hundredths_from_start.to_s)
      expect(rl_form.find("#sublap-save-row-#{sublap_index}")).to be_present
      expect(rl_form.find("span#sublap-delta-#{sublap_index}").text).to include("Δt: #{relay_lap.to_timing}")
    end
  end
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrr
# Sets:
# - @chosen_mrs
# - @chosen_lap_idx
# Clears:
# - @chosen_sublap
#
# rubocop:disable Rails/DynamicFindBy
When('I add a new relay swimmer if allowed or select the last MRS section') do
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)
  mrs_form = dialog.find('form#frm-add-mrs-row', visible: true)
  event_type = @chosen_mrr.event_type
  @chosen_sublap = nil

  # Try to add a new MRS row if there's space for it:
  if event_type.phases > @chosen_mrr.meeting_relay_swimmers.to_a.length
    # == NOTE: ==
    # If the MRS count is < phases, then the option list for badges & lengths
    # should ALWAYS present enough options to fill the form for a new MRS phase.
    #
    # Currently this has this may be false only for Teams that do not have enough
    # swimmers for all the relay phases (but in this case the MRR shouldn't even
    # be there, so it's a non-issue).

    # Select first available badge from list:
    mrs_form.find_by_id('badge_id').find(:xpath, 'option[1]').select_option

    # Select first available length from list:
    mrs_form.find_by_id('length_in_meters').find(:xpath, 'option[1]').select_option

    laps_table = dialog.find('tbody#laps-table-body', visible: true)
    wait_for_ajax && sleep(1)
    before_add = laps_table.find_all('tr td .lap-row').count
    # Click on add MRS row:
    step("I trigger the click event on the '#btn-add-mrs-row' DOM ID")

    # XJS partial re-rending is pretty slow:
    20.times do
      wait_for_ajax && sleep(1)
      break if find_all('tr td .lap-row').count > before_add
    end
  end

  @chosen_mrs = @chosen_mrr.reload.meeting_relay_swimmers.includes(:relay_laps).last # last created
  # Actual MRS index, relative to row rendering order:
  @chosen_lap_idx = @chosen_mrr.meeting_relay_swimmers.by_order.index(@chosen_mrs)
end

# Uses:
# - @chosen_mrr
# Sets:
# - @chosen_mrs: the last MRS wrapping the RelayLap, if any
# - @chosen_lap_idx: MRS/swimmer index
# - @chosen_sublap: chosen RelayLap, always the last one created
#
When('I add a new relay sub-lap if allowed or possibly select the last sub-lap available') do
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  @chosen_mrr.reload
  # Make sure the lap modal edit is visible:
  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)
  dialog.find('tbody#laps-table-body tr td .form-row.lap-row', visible: true)

  @chosen_mrs = @chosen_mrr.meeting_relay_swimmers.includes(:relay_laps).last # last created
  expect(@chosen_mrs).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid

  event_type = @chosen_mrr.event_type
  # Actual MRS index, relative to row rendering order:
  @chosen_lap_idx = @chosen_mrr.meeting_relay_swimmers.by_order.index(@chosen_mrs)
  max_relay_laps = (event_type.phase_length_in_meters / 50) - 1

  # Try to add a new sublap row if there's space for it:
  raise("\r\n--> WARNING: sublap add step called on wrong MeetingEvent (<100m)!") if event_type.phase_length_in_meters < 100

  # Detect if there are any free sublap slots available (which will make the "add sublap" button available):
  if @chosen_mrs.relay_laps.to_a.length < max_relay_laps
    wait_for_ajax
    sleep(1)
    # The lap/add button will be on the bottom of the page on very small screen displays:
    step('I scroll toward the end of the page to see the bottom of the page')
    before_add = find_all('tr td .form-row.lap-row').count

    # Drag the button onto itself to make it in the viewport, in case it isn't:
    btn = find("a#lap-new50-#{@chosen_mrs.id}")
    btn.drag_to(btn)
    wait_for_ajax
    sleep(0.5)
    step("I trigger the click event on the '#lap-new50-#{@chosen_mrs.id}' DOM ID")

    # XJS partial re-rending is pretty slow:
    20.times do
      break if find_all('tr td .form-row.lap-row').count > before_add

      wait_for_ajax
      sleep(0.5)
      putc '+'
    end
    expect(find_all('tr td .form-row.lap-row').count).to be > before_add
  end

  # Mark as chosen the last created sublap in any case:
  @chosen_mrs.reload
  @chosen_sublap = @chosen_mrs.relay_laps.last
  expect(@chosen_sublap).to be_a(GogglesDb::RelayLap).and be_valid
end
# rubocop:enable Rails/DynamicFindBy
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrr
# - @chosen_mrs & @chosen_lap_idx
# Sets:
# - @edited_timing
#
When('I fill the last relay swimmer row with some random timing values') do
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  expect(@chosen_mrs.id).to be_positive
  # Avoid Bullet complaining about missing eager loading:
  @chosen_mrs = GogglesDb::MeetingRelaySwimmer.includes(:relay_laps).find(@chosen_mrs.id)
  expect(@chosen_mrs).to be_valid

  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)
  event_type = @chosen_mrr.event_type
  overall_index = (@chosen_lap_idx + 1) * (event_type.phase_length_in_meters / 50)

  # Make sure the form is visible, compute the fake timing and fill it in:
  dialog.find("form#frm-lap-row-#{overall_index}", visible: true)
  @edited_timing = Timing.new.from_hundredths((@chosen_mrr.to_timing.to_hundredths / event_type.phases) * (@chosen_lap_idx + 1))

  fill_in("minutes_from_start_#{overall_index}", with: @edited_timing.minutes)
  fill_in("seconds_from_start_#{overall_index}", with: @edited_timing.seconds)
  fill_in("hundredths_from_start_#{overall_index}", with: @edited_timing.hundredths)
end

# Uses:
# - @chosen_mrr
# - @chosen_mrs & @chosen_lap_idx
# - @chosen_sublap
# Sets:
# - @edited_timing
#
When('I fill the last sub-lap row with some random timing values') do
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  expect(@chosen_mrs).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
  expect(@chosen_sublap).to be_a(GogglesDb::RelayLap).and be_valid

  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)
  event_type = @chosen_mrr.event_type
  chosen_sublap_idx = @chosen_mrs.relay_laps.order(:length_in_meters).index(@chosen_sublap)
  overall_index = (@chosen_lap_idx * event_type.phase_length_in_meters / 50) + chosen_sublap_idx + 1 # Index relative to all sub-laps (RelayLaps)

  # Make sure the form is visible, compute the fake timing and fill it in:
  dialog.find("form#frm-sublap-row-#{overall_index}", visible: true)

  @edited_timing = Timing.new.from_hundredths(
    overall_index * (@chosen_mrs.to_timing.to_hundredths / (event_type.phase_length_in_meters / 50))
  )

  fill_in("minutes_from_start_#{overall_index}", with: @edited_timing.minutes)
  fill_in("seconds_from_start_#{overall_index}", with: @edited_timing.seconds)
  fill_in("hundredths_from_start_#{overall_index}", with: @edited_timing.hundredths)
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrr & @chosen_mrs
# - @chosen_lap_idx
# - @chosen_sublap, only when set after adding a sublap
#
# Params:
# - lap_type: either 'lap' or 'sublap'
#
When('I click to save my edited relay {string} row') do |lap_type|
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  expect(@chosen_mrs).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
  event_type = @chosen_mrr.event_type
  overall_index = if @chosen_sublap
                    chosen_sublap_idx = @chosen_mrs.relay_laps.order(:length_in_meters).index(@chosen_sublap)
                    (@chosen_lap_idx * event_type.phase_length_in_meters / 50) + chosen_sublap_idx + 1
                  else
                    (@chosen_lap_idx + 1) * (event_type.phase_length_in_meters / 50)
                  end
  # Make sure the form is rendered, then save the row:
  find("tbody tr td form#frm-#{lap_type}-row-#{overall_index}", visible: true)
  step("I trigger the click event on the '##{lap_type}-save-row-#{overall_index}' DOM ID")
end
# -----------------------------------------------------------------------------

Then('I see a successful flash notice on the lap-editor dialog header') do
  dialog = find_by_id('lap-edit-modal', class: 'modal', visible: true)
  expect(dialog.find('.modal-header .alert-success#lap-modal-alert #lap-modal-alert-text')).to be_present
end

# Uses:
# - @chosen_mrr & @chosen_mrs
# - @chosen_lap_idx
# - @edited_timing
# - @chosen_sublap, only when set after adding a sublap
#
Then('I see my edited timing are present in the chosen row') do
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  event_type = @chosen_mrr.event_type
  # Depends on currently edited lap type:
  overall_index = if @chosen_sublap
                    chosen_sublap_idx = @chosen_mrs.relay_laps.order(:length_in_meters).index(@chosen_sublap)
                    (@chosen_lap_idx * event_type.phase_length_in_meters / 50) + chosen_sublap_idx + 1
                  else
                    (@chosen_lap_idx + 1) * (event_type.phase_length_in_meters / 50)
                  end
  find_by_id('lap-edit-modal', class: 'modal', visible: true) # Make sure the dialog is visible first
  expect(find("input#minutes_from_start_#{overall_index}").value).to eq(@edited_timing.minutes.to_s)
  expect(find("input#seconds_from_start_#{overall_index}").value).to eq(@edited_timing.seconds.to_s)
  expect(find("input#hundredths_from_start_#{overall_index}").value).to eq(@edited_timing.hundredths.to_s)
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrr & @chosen_mrs
When('I expand the chosen MRR details') do
  expect(@chosen_mrr).to be_a(GogglesDb::MeetingRelayResult).and be_valid
  # Make sure the result row is there:
  mrr_row = find("tbody.result-table-row#mrr#{@chosen_mrr.id}", visible: true)

  # No details to expand? Skip the test:
  if mrr_row.has_css?('label.switch-sm span')
    3.times do
      break if find("small#detail-mrs#{@chosen_mrs.id}").visible?

      toggle_id = mrr_row.find('label.switch-sm span', visible: true)[:id] unless find("small#detail-mrs#{@chosen_mrs.id}").visible?
      step("I trigger the click event on the '##{toggle_id}' DOM ID")
      # Wait for the expand animation to finish
      10.times do
        break if find("small#detail-mrs#{@chosen_mrs.id}").visible?

        putc '.'
        wait_for_ajax
        sleep(0.5)
      end
      putc 'R' # signal repeat click&loop
    end
    # UPDATE: ignore if the switch didn't receive to the click event and just move on.
    # (see also step implementation below)
  end
end
# -----------------------------------------------------------------------------

# UPDATE: due to "flakyness" in expanding the section using the step above,
# we will check the contents ignoring the visibility flag of all nodes below.
#
# Uses:
# - chosen_mrr & @chosen_mrs
# - @edited_timing
Then('I see the chosen MRS row has updated the MRR details') do
  expect(@chosen_mrs).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
  @chosen_mrs.reload
  find("tbody#laps-show#{@chosen_mrr.id}")

  # The @edited_timing is a bit of a hack and may become negative/with hours,
  # so we basically ignore the minutes and just check the seconds and 1/100ths:
  significant_bit = @edited_timing.to_s.split(/\d'/).last

  # XJS partial re-rending is pretty slow:
  30.times do
    break if find("small#detail-mrs#{@chosen_mrs.id}").text.include?("#{significant_bit} ⏱")

    wait_for_ajax
    sleep(0.5)
    putc '@'
  end
  expect(find("small#detail-mrs#{@chosen_mrs.id}").text).to include("#{significant_bit} ⏱")
end

# (Synonym of the above)
# Uses:
# - @chosen_mrs
# - @edited_timing
Then('I see the chosen sub-lap row has updated the MRR details in the event section') do
  step('I see the chosen MRS row has updated the MRR details')
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrs
# - @chosen_lap_idx
# Updates:
# - @chosen_lap_idx, with the row count before deletion
#
When('I click to delete my chosen relay swimmer and confirm the deletion') do
  expect(@chosen_mrs).to be_a(GogglesDb::MeetingRelaySwimmer).and be_valid
  @chosen_mrs.reload
  event_type = @chosen_mrr.event_type
  overall_index = (@chosen_lap_idx + 1) * (event_type.phase_length_in_meters / 50)

  before_deletion = find_all('tbody#laps-table-body tr td .lap-row').count
  step("I click on '#lap-delete-row-#{overall_index}' accepting the confirmation request")

  # XJS partial re-rending is pretty slow:
  30.times do
    putc 'S' # Signal "*S*low" retry
    find('tbody#laps-table-body')
    wait_for_ajax
    sleep(0.5)
    break if find_all('tbody#laps-table-body tr td .lap-row').count < before_deletion
  end
  expect(find_all('tbody#laps-table-body tr td .lap-row').count).to be < before_deletion
  @chosen_lap_idx = before_deletion
end
# -----------------------------------------------------------------------------

# Uses:
# - @chosen_mrs
Then('The chosen MRS row is not shown anymore in the MRR details') do
  expect(page).to have_no_css("small#detail-mrs#{@chosen_mrs.id}")
end
