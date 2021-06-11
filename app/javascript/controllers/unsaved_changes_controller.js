import { Controller } from 'stimulus'

/**
 * = StimulusJS "unsaved changes" detection controller =
 *
 * Allows to check & toggle an internal "has unsaved changes" ('changed') flag for
 * forms or individual edit fields that are prone to data loss when leaving the page without
 * actually submitting the edited data.
 *
 * == How ==
 * - the target field must be wrapped with a parent connected to the controller;
 * - form (or page container) pre-sets a 'data' attribute with the default value of the 'changed' flag (clear);
 * - form (/page container) listens to unload/visit events to intercept & block leaving of the page;
 * - any field subject to change should trigger the flag setter in this controller by binding a 'data-action' to it;
 * - only a 'Post/Save' or 'Cancel' button should clear the flag & allow data submission or page change.
 *
 * == Targets ==
 * (none)
 *
 * == Values ==
 * (no static values)
 * Uses simple 'data' attributes:
 * @param {String} 'data-unsaved-changes-changed' => 'false' (flag, default value)
 * @param {String} 'data-unsaved-changes-message' => any "you have unsaved changes"-kind of message
 *
 * == Actions:
 * - Page/Form should bind to:
 *    - 'beforeunload@window->unsaved-changes#leavingPage'
 *    - 'turbolinks:before-visit@window->unsaved-changes#leavingPage'
 *
 * - Edit fields should bind to:
 *    - 'change->unsaved-changes#formIsChanged'
 *
 * - Post/Cancel button should bind to:
 *    - 'unsaved-changes#allowFormSubmission'
 *
 * @author Steve A.
 * Original idea: @see https://onrails.blog/2018/05/08/stimulus-js-tutorial-dont-lose-unsaved-form-fields/
 */
export default class extends Controller {
  /**
   * Sets the 'changed' flag
   */
  formIsChanged (event) {
    this.setChanged('true')
  }

  /**
   * Clears the 'changed' flag
   */
  allowFormSubmission (_event) {
    this.setChanged('false')
  }

  /**
   * 'changed' flag getter
   */
  isFormChanged () {
    return this.data.get('changed') === 'true'
  }

  /**
   * Prevents data submission if the 'changed' flag is set
   */
  leavingPage (event) {
    if (this.isFormChanged()) {
      const msg = this.data.get('message')
      if (event.type === 'turbolinks:before-visit') {
        if (!window.confirm(msg)) {
          event.preventDefault()
        }
      } else {
        event.returnValue = msg
        return event.returnValue
      }
    }
  }

  /**
   * Data-attribute 'changed' flag setter
   */
  setChanged (changed) {
    this.data.set('changed', changed)
  }
}
