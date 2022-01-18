import { Controller } from '@hotwired/stimulus'

/**
 * = StimulusJS controller: summary updater for /chrono/new wizard form =
 *
 * Updates the final summary at the end of the wizard-form process used by
 * /chrono/new, before starting a new chrono recording.
 *
 * The required targets act also as validators (enable/disable the submit button).
 *
 *
 * == Targets ==
 * @param {String} 'data-chrono-new-summary-target': 'title'
 *                 destination node for the summary title (meeting or workshop).
 *
 * @param {String} 'data-chrono-new-summary-target': 'event'
 *                 destination for the summary event label.
 *
 * @param {String} 'data-chrono-new-summary-target': 'pool'
 *                 destination node for the summary swimming pool label.
 *
 * @param {String} 'data-chrono-new-summary-target': 'swimmer'
 *                 destination node for the summary swimmer description.
 *
 * @param {String} 'data-chrono-new-summary-target': 'submit'
 *                 destination node for the summary 'submit' button; if all of the above
 *                 have values, the button will be enabled.
 *
 *
 * == Assumptions / Reserved source IDs ==
 * @assert only 1 ChronoNewSummaryController per page
 * Required *source* node IDs; each one should store a value to display in the summary:
 *
 * - '#rec_type' ('1' => show meeting label; '2' => show user-workshop label)
 * - '#meeting_label'
 * - '#user_workshop_label'
 * - '#swimmer_label'
 * - '#swimming_pool_label'
 * - '#event_label'
 *
 * If all of the nodes above have values the final submit button of the form will be enabled
 * (otherwise it won't be).
 *
 * Additional IDs (not required):
 *
 * - '#required-ready' => if present, displayed when all required fields are filled-in
 * - '#required-missing' => if present, displayed when some required fields are missing
 *
 *
 * == Values ==
 * (no static values)
 *
 *
 * == Actions:
 * Fields triggering the update should bind 'data-action' to:
 *    - '<EVENT>->chrono-new-summary#updateSummary', with <EVENT> being any triggered event (i.e. 'change',
 *      'input', 'click', ...)
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['title', 'event', 'pool', 'swimmer', 'submit']

  /**
   * Sets up the controller.
   */
  connect () {
    this.setUp()
  }

  /**
   * Sets the event handlers for the associated wizard-form and all the
   * other customized display details.
   */
  setUp() {
    // DEBUG
    // console.log('Setting-up chrono-new-summary...')
    if (!this.hasTitleTarget || !this.hasEventTarget || !this.hasPoolTarget ||
        !this.hasSwimmerTarget || !this.hasSubmitTarget) {
      console.warn('Required target(s) for wizard-form missing: skipping setup.')
      return
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Updates the summary and enables or disables the submit action.
   * @param {Object} event the event from the call.
   */
  updateSummary(_event) {
    // DEBUG
    console.log('updateSummary()')

    const meetingLabel = this.getMeetingLabel()
    const eventTypeLabel = document.getElementById('event_type_label') ? document.getElementById('event_type_label').value : ''
    const eventDate = document.getElementById('event_date') ? document.getElementById('event_date').value : ''
    const poolLabel = document.getElementById('swimming_pool_label') ? document.getElementById('swimming_pool_label').value : ''
    const swimmerLabel = document.getElementById('swimmer_label') ? document.getElementById('swimmer_label').value : ''

    this.titleTarget.innerHTML = meetingLabel
    this.eventTarget.innerHTML = `${eventDate} - ${eventTypeLabel}`
    this.poolTarget.innerHTML = poolLabel
    this.swimmerTarget.innerHTML = swimmerLabel

    if (meetingLabel.length > 0 && eventTypeLabel.length > 0 && eventDate.length > 0 &&
      poolLabel.length > 0 && swimmerLabel.length > 0) {
      this.submitTarget.disabled = false
      document.getElementById('required-ready').classList.remove('d-none')
      document.getElementById('required-missing').classList.add('d-none')
    }
    else {
      this.submitTarget.disabled = true
      document.getElementById('required-ready').classList.add('d-none')
      document.getElementById('required-missing').classList.remove('d-none')
    }
    return true
  }
  // ---------------------------------------------------------------------------

  /**
   * @returns the String description for the Meeting or Workshop, depending on the switch value.
   */
  getMeetingLabel() {
    if (document.getElementById('rec_type').value === '1') {
      return document.getElementById('meeting_label').value
    }
    else {
      return document.getElementById('user_workshop_label').value
    }
  }
  // ---------------------------------------------------------------------------
}
