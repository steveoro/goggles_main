import { Controller } from 'stimulus'
import $ from 'jquery'

/**
 * = StimulusJS controller for Pop-overs, Modals & Tooltips =
 *
 * Allows popover, modal & tooltip initialization without adding
 * page/load event listeners for Turbo/Turbolinks.
 *
 * Setup is performed on controller instance binding: as long as the
 * page is connected to this controller, any initialization will be automatically
 * done for:
 * - data-toggle="tooltip"
 * - data-toggle="modal"
 * - data-toggle="popover"
 *
 * (Typically, this controller is bound to the application layout, so that there's
 * no need to duplicate the data-controller code on each view.)
 *
 * == Targets ==
 * (no static targets)
 *
 * == Values ==
 * (no static values)
 *
 * == Actions:
 * (no actions, just setup)
 *
 * @author Steve A.
 */
export default class extends Controller {
  /**
   * Sets up the controller.
   * (Called whenever the controller instance connects to the DOM)
   */
  connect () {
    // DEBUG
    // console.log('Connecting popover controller...')

    // *** Popovers setup: ***
    $('[data-toggle="popover"]').popover()

    // *** Tooltips setup: ***
    $('[data-toggle="tooltip"]').tooltip()
    // Auto-hide all tooltips after they've being shown:
    $('[data-toggle="tooltip"]').on('shown.bs.tooltip', function () {
      $('[data-toggle="tooltip"]').delay(2000).queue(function (next) {
        $(this).tooltip('hide')
        next()
      })
    })

    // *** Alerts setup: ***
    $('.alert').alert().fadeTo(500, 1).delay(2500).slideUp(250, function () {
      $('.alert').alert('close')
    })

    // *** Modals setup: ***
    // Show & auto-hide all modals after a while:
    // $('[data-toggle="modal"]').modal().fadeTo(250, 1).delay(1000).slideUp(250, function () {
    $('[data-toggle="modal"]').modal().delay(2000).slideUp(250, function () {
      $('[data-toggle="modal"]')
        .modal('hide')
        .on('hidden.bs.modal', function (e) {
          // Remove content after show: (no need for the time being)
          // document.querySelectorAll('[data-toggle="modal"]').forEach(element => element.remove())
        })
    })
  }
  // ---------------------------------------------------------------------------
}
