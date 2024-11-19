import { Controller } from '@hotwired/stimulus'
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
    $('.flash-alert.alert').alert().fadeTo(500, 1).delay(2500).slideUp(250, function () {
      $('.flash-alert.alert').alert('close')
    })

    // *** Modals setup: ***
    // (none so far)

    // *** Collapsible sections with switchable "More..."/"Less..." label setup: ***
    $('.switchable-label-collapse').on('shown.bs.collapse', function () {
      $('#show-more-or-less').removeClass('fa-plus')
      $('#show-more-or-less').addClass('fa-minus')
    })
    $('.switchable-label-collapse').on('hidden.bs.collapse', function () {
      $('#show-more-or-less').removeClass('fa-minus')
      $('#show-more-or-less').addClass('fa-plus')
    })
  }
  // ---------------------------------------------------------------------------
}
