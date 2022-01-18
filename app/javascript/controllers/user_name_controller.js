import { Controller } from '@hotwired/stimulus'

/**
 * = StimulusJS controller for user email & name edits =
 *
 * Contains simple trigger actions to update user's first & last name
 * upon editing the e-mail address (tries to guess full name from email) or
 * simply update the full name description whenever the first & last name
 * part changes.
 *
 * == Targets ==
 * @param {String} 'data-user-name-target': 'name'
 *                 input field for user name
 *
 * @param {String} 'data-user-name-target': 'description'
 *                 input field for "full user description"
 *
 * @param {String} 'data-user-name-target': 'email'
 *                 input field for user email
 *
 * @param {String} 'data-user-name-target': 'first'
 *                 input field for user first name
 *
 * @param {String} 'data-user-name-target': 'last'
 *                 input field for user last name
 *
 * == Values ==
 * (no static values)
 *
 * == Actions:
 * Bind triggers to any <EVENT> (i.e. 'change', 'input', 'click', ...)
 * - '<EVENT>->user-name#updateDescription' => updates "description" from first + last name
 * - '<EVENT>->user-name#updateNames' => updates 'name', 'first' & 'last' name parts from email
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['description', 'email', 'name', 'first', 'last']

  /**
   * Sets up the controller.
   * (Called whenever the controller instance connects to the DOM)
   */
  connect () {
    // DEBUG
    // console.log('Connecting user-edit...')
  }
  // ---------------------------------------------------------------------------

  /**
   * Updates: edits on 'first' & 'last' targets |=> 'description' target
   */
  updateDescription () {
    if (this.hasDescriptionTarget && this.hasFirstTarget && this.hasLastTarget) {
      this.descriptionTarget.value.value = `${this.firstTarget.value} ${this.lastTarget.value}`
    }
  }

  /**
   * Updates: edits on 'email' target |=> 'name', 'first' & 'last' targets
   */
  updateNames () {
    if (this.hasEmailTarget && this.hasNameTarget && this.hasFirstTarget && this.hasLastTarget) {
      const splitEMail = this.emailTarget.value.split('@')[0]
      this.nameTarget.value = splitEMail
      const splitNames = splitEMail.split(/[_.-]/)
      this.firstTarget.value = this.titleize(splitNames[0])
      this.lastTarget.value = this.titleize(splitNames[1])
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Convert a string 'word' to 'Word'.
   * @param {String} word the word to be "titleized"
   * @return word, with first letter converted to upper case
   */
  titleize (word) {
    return word[0].toUpperCase() + word.substring(1)
  }
}
